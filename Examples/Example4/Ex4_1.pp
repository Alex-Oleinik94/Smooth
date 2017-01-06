{$INCLUDE SaGe.inc}
{$IFDEF ENGINE}
	unit Ex4_1;
	interface
{$ELSE}
	program Example4_1;
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
	,SaGeRenderConstants
	,SaGeUtils
	,SaGeScreen
	,SaGeCommon
	;
type
	TSGExample4_1=class(TSGDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSGString;override;
			private
		FCamera : TSGCamera;
		FBuffer : LongWord;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSGExample4_1.ClassName():TSGString;
begin
Result := 'Вывод неиндексированым массивом с VBO';
end;

constructor TSGExample4_1.Create(const VContext : ISGContext);
var
	i:TSGByte;
	FArray  : packed array of 
		packed record
			FVertex:TSGVertex3f;
			FColor:TSGColor4b;
			end;
begin
inherited Create(VContext);
FCamera:=TSGCamera.Create();
FCamera.SetContext(Context);
FBuffer:=0;
SetLength(FArray,36);

// Первый квадрат, состоящий из 2x треугольников
i:=0;
FArray[i+0].FVertex.Import(1,1,1);
FArray[i+0].FColor .Import(255,255,255,255);
FArray[i+1].FVertex.Import(1,1,-1);
FArray[i+1].FColor .Import(255,255,0,255);
FArray[i+2].FVertex.Import(1,-1,-1);
FArray[i+2].FColor .Import(255,0,255,255);
FArray[i+3].FVertex.Import(1,-1,1);
FArray[i+3].FColor .Import(0,255,255,255);
FArray[i+4]:=FArray[i+0];
FArray[i+5]:=FArray[i+2];

// Второй квадрат
i+=6;
FArray[i+0]:=FArray[0];
FArray[i+1]:=FArray[3];
FArray[i+2].FVertex.Import(-1,-1,1);
FArray[i+2].FColor .Import(255,0,0,255);
FArray[i+3].FVertex.Import(-1,1,1);
FArray[i+3].FColor .Import(0,0,255,255);
FArray[i+4]:=FArray[i+0];
FArray[i+5]:=FArray[i+2];

// Третий квадрат
i+=6;
FArray[i+0]:=FArray[3];
FArray[i+1]:=FArray[2];
FArray[i+2].FVertex.Import(-1,-1,-1);
FArray[i+2].FColor .Import(0,0,0);
FArray[i+3]:=FArray[8];
FArray[i+4]:=FArray[i+0];
FArray[i+5]:=FArray[i+2];

// Четвертый квадрат
i+=6;
FArray[i+0]:=FArray[0];
FArray[i+1]:=FArray[9];
FArray[i+2].FVertex.Import(-1,1,-1);
FArray[i+2].FColor .Import(0,255,0,255);
FArray[i+3]:=FArray[1];
FArray[i+4]:=FArray[i+0];
FArray[i+5]:=FArray[i+2];

// Пятый квадрат
i+=6;
FArray[i+0]:=FArray[9];
FArray[i+1]:=FArray[3*6+2];
FArray[i+2]:=FArray[2*6+2];
FArray[i+3]:=FArray[8];
FArray[i+4]:=FArray[i+0];
FArray[i+5]:=FArray[i+2];

// Шестой квадрат
i+=6;
FArray[i+0]:=FArray[1];
FArray[i+1]:=FArray[2];
FArray[i+2]:=FArray[2*6+2];
FArray[i+3]:=FArray[3*6+2];
FArray[i+4]:=FArray[i+0];
FArray[i+5]:=FArray[i+2];

// В DirectX можно использовать цвета в формате UNSIGNED_BYTE как (b;g;r;a).
// А в OpenGL можно использовать как FLOAT (r;g;b) и (r;g;b;a), так и UNSIGNED_BYTE (r;g;b) и (r;g;b;a).
// И получается, что синий и красный цвета меняются местами. Поэтому мы их меняем обратно.
// Для решения этой проблемы реализован класс TSGMesh, которы сам делает все эти операции, 
//   и поддерживает работу с разными форматами цветов одной процедурой.
if Render.RenderType=SGRenderOpenGL then
	for i:=Low(FArray) to High(FArray) do
		FArray[i].FColor.ConvertType();

Render.GenBuffersARB(1,@FBuffer);
Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,FBuffer);
Render.BufferDataARB(SGR_ARRAY_BUFFER_ARB,Length(FArray)*(SizeOf(TSGVertex3f)+SizeOf(TSGColor4b)),@FArray[0], SGR_STATIC_DRAW_ARB);
Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,0);

SetLength(FArray,0);
end;

destructor TSGExample4_1.Destroy();
begin
Render.DeleteBuffersARB(1,@FBuffer);
inherited;
end;

procedure TSGExample4_1.Paint();
begin
FCamera.CallAction();

Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,FBuffer);

Render.EnableClientState(SGR_VERTEX_ARRAY);
Render.EnableClientState(SGR_COLOR_ARRAY);

Render.VertexPointer(3, SGR_FLOAT,         SizeOf(TSGVertex3f)+SizeOf(TSGColor4b), nil);
Render.ColorPointer (4, SGR_UNSIGNED_BYTE, SizeOf(TSGVertex3f)+SizeOf(TSGColor4b), Pointer(SizeOf(TSGVertex3f)));

Render.DrawArrays(SGR_TRIANGLES, 0, 36);

Render.DisableClientState(SGR_COLOR_ARRAY);
Render.DisableClientState(SGR_VERTEX_ARRAY);

Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,0);
end;

{$IFNDEF ENGINE}
	begin
	ExampleClass := TSGExample4_1;
	RunApplication();
	end.
{$ELSE}
	end.
	{$ENDIF}
