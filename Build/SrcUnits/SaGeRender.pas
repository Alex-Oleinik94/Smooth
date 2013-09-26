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
			protected
		FWindow:TSGClass;
			public
		procedure MakeCurrent();virtual;abstract;
		function CreateContext():Boolean;virtual;abstract;
		procedure Viewport(const a,b,c,d:LongWord);virtual;abstract;
		procedure Init();virtual;abstract;
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
		procedure Enable(const VParam:LongWord);virtual;abstract;
		procedure Disable(const VParam:LongWord);virtual;abstract;
		procedure DeleteTextures(const VQuantity:LongWord;const VTextures:PSGUInt);virtual;abstract;
		procedure Lightfv(const VLight,VParam:LongWord;const VParam2:Pointer);virtual;abstract;
		procedure GenTextures(const VQuantity:LongWord;const VTextures:PSGUInt);virtual;abstract;
		procedure BindTexture(const VParam:LongWord;const VTexture:SGUInt);virtual;abstract;
		procedure TexParameteri(const VP1,VP2,VP3:LongWord);virtual;abstract;
		procedure PixelStorei(const VParamName:LongWord;const VParam:SGInt);virtual;abstract;
		procedure TexEnvi(const VP1,VP2,VP3:LongWord);virtual;abstract;
		procedure TexImage2D(const VTextureType:LongWord;const VP1:LongWord;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:LongWord;const VBitMap:Pointer);virtual;abstract;
			public
		property Window:TSGClass read FWindow write FWindow;
		end;
	
	TSGRenderObject=class(TSGClass)
			public
		FRender:TSGRender;
			public
		property Render:TSGRender read FRender write FRender;
		end;

implementation

constructor TSGRender.Create;
begin
FWindow:=nil;
end;

destructor TSGRender.Destroy;
begin
inherited;
end;

end.
