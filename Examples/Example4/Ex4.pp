{$INCLUDE SaGe.inc}
program Example3;
uses
	{$IFDEF UNIX}
		{$IFNDEF ANDROID}
			cthreads,
			{$ENDIF}
		{$ENDIF}
	SaGeContext
	,SaGeBased
	,SaGeBase
	,SaGeRender
	,SaGeBaseExample
	,SaGeUtils
	,SaGeScreen
	,SaGeCommon
	;
type
	TSGExample=class(TSGDrawClass)
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
		FBuffer:LongWord;
		end;

class function TSGExample.ClassName():TSGString;
begin
Result := 'Вывод массивом';
end;

constructor TSGExample.Create(const VContext : TSGContext);
var
	i:TSGByte;
begin
inherited Create(VContext);
FCamera:=TSGCamera.Create();
FCamera.SetContext(Context);
FBuffer:=0;

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

Render.GenBuffersARB(1,@FBuffer);
Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,FBuffer);
Render.BufferDataARB (SGR_ARRAY_BUFFER_ARB,SizeOf(FArray),@FArray[0], SGR_STATIC_DRAW_ARB);
Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,0);
end;

destructor TSGExample.Destroy();
begin
Render.DeleteBuffersARB(1,@FBuffer);
inherited;
end;

procedure TSGExample.Draw();
begin
FCamera.CallAction();

Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,FBuffer);

Render.EnableClientState(SGR_VERTEX_ARRAY);
Render.EnableClientState(SGR_COLOR_ARRAY);

Render.VertexPointer(3, SGR_FLOAT, SizeOf(FArray[0]), Pointer(0));
// А вод тут у нас проблемка. 
// Дело в том, что в DirectX можно использовать цвета в формате SGR_UNSIGNED_BYTE как (b;g;r;a).
// А в OpenGL можно использовать как SGR_FLOAT (r;g;b) и (r;g;b;a), так и SGR_UNSIGNED_BYTE (r;g;b) и (r;g;b;a).
// И получается, что синий и красный цвета меняются местами.
// Для решения этой проблемы реализован класс TSGMesh.
Render.ColorPointer(4, SGR_UNSIGNED_BYTE, SizeOf(FArray[0]), Pointer(TSGMaxEnum(@FArray[0].FColor)-TSGMaxEnum(@FArray[0].FVertex)));

Render.DrawArrays(SGR_TRIANGLES, 0, Length(FArray));

Render.DisableClientState(SGR_COLOR_ARRAY);
Render.DisableClientState(SGR_VERTEX_ARRAY);

Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,0);
end;

begin
ExampleClass := TSGExample;
RunApplication();
end.
