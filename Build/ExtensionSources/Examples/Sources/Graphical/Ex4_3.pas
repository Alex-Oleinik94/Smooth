{$INCLUDE Smooth.inc}
{$IFDEF ENGINE}
	unit Ex4_3;
	interface
{$ELSE}
	program Example4_3;
	{$ENDIF}
uses
	{$IF defined(UNIX) and (not defined(ANDROID)) and (not defined(ENGINE))}
		cthreads,
		{$ENDIF}
	 SmoothContextInterface
	,SmoothContextClasses
	,SmoothBase
	,SmoothRenderBase
	,SmoothFont
	,SmoothScreen
	,SmoothCommonStructs
	,SmoothCamera
	{$IF not defined(ENGINE)}
		,SmoothConsolePaintableTools
		,SmoothConsoleHandler
		{$ENDIF}
	;
type
	TSExample4_3 = class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSString;override;
			private
		FCamera : TSCamera;
		FBufferArray:LongWord;
		FBufferIndexes:LongWord;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSExample4_3.ClassName():TSString;
begin
Result := 'Куб (индексированый массив и VBO)';
end;

constructor TSExample4_3.Create(const VContext : ISContext);
var
	FArray  : packed array of 
		packed record
			FVertex:TSVertex3f;
			FColor:TSColor4b;
			end;
	FIndexes:packed array of
		TSWord;
	i : TSByte;
begin
inherited Create(VContext);
FCamera:=TSCamera.Create();
FCamera.SetContext(Context);

FBufferArray:=0;
FBufferIndexes:=0;

SetLength(FArray,8);
SetLength(FIndexes,36);

FArray[0].FVertex.Import(1,1,1);
FArray[0].FColor .Import(255,255,255,255);
FArray[1].FVertex.Import(1,1,-1);
FArray[1].FColor .Import(255,255,0,255);
FArray[2].FVertex.Import(1,-1,-1);
FArray[2].FColor .Import(255,0,255,255);
FArray[3].FVertex.Import(1,-1,1);
FArray[3].FColor .Import(0,255,255,255);
FArray[4].FVertex.Import(-1,-1,1);
FArray[4].FColor .Import(255,0,0,255);
FArray[5].FVertex.Import(-1,1,1);
FArray[5].FColor .Import(0,0,255,255);
FArray[6].FVertex.Import(-1,-1,-1);
FArray[6].FColor .Import(0,0,0,255);
FArray[7].FVertex.Import(-1,1,-1);
FArray[7].FColor .Import(0,255,0,255);

// Первый квадрат, состоящий из 2x треугольников
i:=0;
FIndexes[i+0]:=0;
FIndexes[i+1]:=1;
FIndexes[i+2]:=2;
FIndexes[i+3]:=3;
FIndexes[i+4]:=FIndexes[i+0];
FIndexes[i+5]:=FIndexes[i+2];

// Второй квадрат
i+=6;
FIndexes[i+0]:=0;
FIndexes[i+1]:=3;
FIndexes[i+2]:=4;
FIndexes[i+3]:=5;
FIndexes[i+4]:=FIndexes[i+0];
FIndexes[i+5]:=FIndexes[i+2];

// Третий квадрат
i+=6;
FIndexes[i+0]:=3;
FIndexes[i+1]:=2;
FIndexes[i+2]:=6;
FIndexes[i+3]:=4;
FIndexes[i+4]:=FIndexes[i+0];
FIndexes[i+5]:=FIndexes[i+2];

// Четвертый квадрат
i+=6;
FIndexes[i+0]:=0;
FIndexes[i+1]:=5;
FIndexes[i+2]:=7;
FIndexes[i+3]:=1;
FIndexes[i+4]:=FIndexes[i+0];
FIndexes[i+5]:=FIndexes[i+2];

// Пятый квадрат
i+=6;
FIndexes[i+0]:=5;
FIndexes[i+1]:=7;
FIndexes[i+2]:=6;
FIndexes[i+3]:=4;
FIndexes[i+4]:=FIndexes[i+0];
FIndexes[i+5]:=FIndexes[i+2];

// Шестой квадрат
i+=6;
FIndexes[i+0]:=1;
FIndexes[i+1]:=2;
FIndexes[i+2]:=6;
FIndexes[i+3]:=7;
FIndexes[i+4]:=FIndexes[i+0];
FIndexes[i+5]:=FIndexes[i+2];

// А вод тут у нас проблемка. 
// Дело в том, что в DirectX можно использовать цвета в формате UNSIGNED_BYTE как (b;g;r;a).
// А в OpenGL можно использовать как FLOAT (r;g;b) и (r;g;b;a), так и UNSIGNED_BYTE (r;g;b) и (r;g;b;a).
// И получается, что синий и красный цвета меняются местами. Поэтому мы их меняем обратно.
// Для решения этой проблемы реализован класс TSMesh, которы сам делает все эти операции, 
//   и поддерживает работу с разными форматами цветов одной процедурой.
if Render.RenderType=SRenderOpenGL then
	for i:=Low(FArray) to High(FArray) do
		FArray[i].FColor.ConvertType();

Render.GenBuffersARB(1,@FBufferArray);
Render.BindBufferARB(SR_ARRAY_BUFFER_ARB,FBufferArray);
Render.BufferDataARB(SR_ARRAY_BUFFER_ARB,Length(FArray)*(SizeOf(TSVertex3f)+SizeOf(TSColor4b)),@FArray[0], SR_STATIC_DRAW_ARB);
Render.BindBufferARB(SR_ARRAY_BUFFER_ARB,0);

Render.GenBuffersARB(1,@FBufferIndexes);
Render.BindBufferARB(SR_ELEMENT_ARRAY_BUFFER_ARB,FBufferIndexes);
Render.BufferDataARB(SR_ELEMENT_ARRAY_BUFFER_ARB,Length(FIndexes)*SizeOf(TSWord),@FIndexes[0], SR_STATIC_DRAW_ARB);
Render.BindBufferARB(SR_ELEMENT_ARRAY_BUFFER_ARB,0);

SetLength(FIndexes,0);
SetLength(FArray,0);
end;

destructor TSExample4_3.Destroy();
begin
Render.DeleteBuffersARB(1,@FBufferArray);
Render.DeleteBuffersARB(1,@FBufferIndexes);
inherited;
end;

procedure TSExample4_3.Paint();
begin
FCamera.CallAction();

Render.BindBufferARB(SR_ARRAY_BUFFER_ARB,FBufferArray);

Render.EnableClientState(SR_VERTEX_ARRAY);
Render.EnableClientState(SR_COLOR_ARRAY);

Render.VertexPointer(3, SR_FLOAT,         SizeOf(TSVertex3f)+SizeOf(TSColor4b), Pointer(0));
Render.ColorPointer (4, SR_UNSIGNED_BYTE, SizeOf(TSVertex3f)+SizeOf(TSColor4b), Pointer(SizeOf(TSVertex3f)));

Render.BindBufferARB(SR_ELEMENT_ARRAY_BUFFER_ARB,FBufferIndexes);
Render.DrawElements(SR_TRIANGLES, 36, SR_UNSIGNED_SHORT, nil);

Render.DisableClientState(SR_COLOR_ARRAY);
Render.DisableClientState(SR_VERTEX_ARRAY);

Render.BindBufferARB(SR_ARRAY_BUFFER_ARB,         0);
Render.BindBufferARB(SR_ELEMENT_ARRAY_BUFFER_ARB, 0);
end;

{$IFNDEF ENGINE}
	begin
	SConsoleRunPaintable(TSExample4_3, SSystemParamsToConcoleCallerParams());
	{$ENDIF}
end.
