{$include Includes\SaGe.inc}

unit SaGeRender;

interface
uses 
	SaGeBase;
{$include Includes\SaGeRenderConstants.inc}
type
	TSGMatrixMode=LongWord;
	TSGPrimtiveType=LongWord;
	
	TSGRender=class;
	TSGRenderClass=class of TSGRender;
	TSGRender=class(TSGClass)
			public
		constructor Create;override;
		destructor Destroy;override;
		function Width:LongWord;inline;
		function Height:LongWord;inline;
			protected
		FWindow:TSGClass;
			public
		function SetPixelFormat():Boolean;virtual;abstract;overload;
		procedure MakeCurrent();virtual;
		procedure ReleaseCurrent();virtual;abstract;
		function CreateContext():Boolean;virtual;abstract;
		procedure Viewport(const a,b,c,d:LongWord);virtual;abstract;
		procedure Init();virtual;abstract;
		function SupporedGPUBuffers:Boolean;virtual;
		procedure SwapBuffers();virtual;abstract;
		function TopShift(const VFullscreen:Boolean = False):LongWord;virtual;
			public
		procedure InitMatrixMode(const Mode:TSGMatrixMode = SG_3D; const dncht:Real = 120);virtual;abstract;
		procedure LoadIdentity();virtual;abstract;
		procedure Vertex3f(const x,y,z:single);virtual;abstract;
		procedure BeginScene(const VPrimitiveType:TSGPrimtiveType);virtual;abstract;
		procedure EndScene();virtual;abstract;
		
		procedure Color3f(const r,g,b:single);virtual;abstract;
		procedure TexCoord2f(const x,y:single);virtual;abstract;
		procedure Vertex2f(const x,y:single);virtual;abstract;
		procedure Color4f(const r,g,b,a:single);virtual;abstract;
		procedure Normal3f(const x,y,z:single);virtual;abstract;
		procedure Translatef(const x,y,z:single);virtual;abstract;
		procedure Rotatef(const angle:single;const x,y,z:single);virtual;abstract;
		procedure Enable(VParam:Cardinal);virtual;
		procedure Disable(const VParam:Cardinal);virtual;abstract;
		procedure DeleteTextures(const VQuantity:Cardinal;const VTextures:PSGUInt);virtual;abstract;
		procedure Lightfv(const VLight,VParam:Cardinal;const VParam2:Pointer);virtual;abstract;
		procedure GenTextures(const VQuantity:Cardinal;const VTextures:PSGUInt);virtual;abstract;
		procedure BindTexture(const VParam:Cardinal;const VTexture:Cardinal);virtual;abstract;
		procedure TexParameteri(const VP1,VP2,VP3:Cardinal);virtual;abstract;
		procedure PixelStorei(const VParamName:Cardinal;const VParam:SGInt);virtual;abstract;
		procedure TexEnvi(const VP1,VP2,VP3:Cardinal);virtual;abstract;
		procedure TexImage2D(const VTextureType:Cardinal;const VP1:Cardinal;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:Cardinal;var VBitMap:Pointer);virtual;abstract;
		procedure ReadPixels(const x,y:Integer;const Vwidth,Vheight:Integer;const format, atype: Cardinal;const pixels: Pointer);virtual;abstract;
		procedure CullFace(const VParam:Cardinal);virtual;abstract;
		procedure EnableClientState(const VParam:Cardinal);virtual;abstract;
		procedure DisableClientState(const VParam:Cardinal);virtual;abstract;
		procedure GenBuffersARB(const VQ:Integer;const PT:PCardinal);virtual;abstract;
		procedure DeleteBuffersARB(const VQuantity:LongWord;VPoint:Pointer);virtual;abstract;
		procedure BindBufferARB(const VParam:Cardinal;const VParam2:Cardinal);virtual;abstract;
		procedure BufferDataARB(const VParam:Cardinal;const VSize:int64;VBuffer:Pointer;const VParam2:Cardinal);virtual;abstract;
		procedure DrawElements(const VParam:Cardinal;const VSize:int64;const VParam2:Cardinal;VBuffer:Pointer);virtual;abstract;
		procedure ColorPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);virtual;abstract;
		procedure TexCoordPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);virtual;abstract;
		procedure NormalPointer(const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);virtual;abstract;
		procedure VertexPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);virtual;abstract;
		function IsEnabled(const VParam:Cardinal):Boolean;virtual;abstract;
		procedure Clear(const VParam:Cardinal);virtual;abstract;
		procedure LineWidth(const VLW:Single);virtual;abstract;
		procedure PointSize(const PS:Single);virtual;abstract;
			public
		property Window:TSGClass read FWindow write FWindow;
		end;

implementation

function TSGRender.TopShift(const VFullscreen:Boolean = False):LongWord;
begin
Result:=0;
end;

procedure TSGRender.MakeCurrent();
begin
SGLog.Sourse('TSGRender__MakeCurrent() : Error : Call inherited methad!!');
end;

procedure TSGRender.Enable(VParam:Cardinal);
begin 
SGLog.Sourse('TSGRender__Enable(Cardinal) : Error : Call inherited methad!!');
end;

function TSGRender.SupporedGPUBuffers:Boolean;
begin
Result:=False;
end;

constructor TSGRender.Create;
begin
FWindow:=nil;
end;

destructor TSGRender.Destroy;
begin
SGLog.Sourse(['TSGRender__Destroy()']);
inherited;
end;

function TSGRender.Width:LongWord;inline;
begin
Result:=LongWord(FWindow.Get('WIDTH'));
end;

function TSGRender.Height:LongWord;inline;
begin
Result:=LongWord(FWindow.Get('HEIGHT'));
end;

end.
