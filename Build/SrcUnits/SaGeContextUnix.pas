{$I Includes\SaGe.inc}
unit SaGeContextUnix;
interface

uses 
	SaGeBase, SaGeBased
	,SaGeCommon
	,SaGeRender
	,SaGeContext
	;
type
	TSGContextUnix=class(TSGContext)
			public
		constructor Create();override;
		destructor Destroy();override;
			public
		procedure Initialize();override;
		procedure Run();override;
		procedure Messages();override;
		procedure SwapBuffers();override;
		function  GetCursorPosition():TSGPoint2f;override;
		function  GetWindowRect():TSGPoint2f;override;
		function  GetScreenResolution():TSGPoint2f;override;
		procedure InitFullscreen(const b:boolean); override;
		procedure ShowCursor(const b:Boolean);override;
		procedure SetCursorPosition(const a:TSGPoint2f);override;
		function  KeysPressed(const  Index : integer ) : Boolean;override;overload;
			public
		
		
		function  CreateWindow():Boolean;
			public
		function Get(const What:string):Pointer;override;
		end;
implementation

function TSGContextUnix.Get(const What:string):Pointer;
begin
{if What='WINDOW HANDLE' then
	Result:=Pointer(hWindow)
else if What='DESCTOP WINDOW HANDLE' then
	Result:=Pointer(dcWindow)
else}
	Result:=Inherited Get(What);
end;

function TSGContextUnix.KeysPressed(const  Index : integer ) : Boolean;overload;
begin

end;

procedure TSGContextUnix.SetCursorPosition(const a:TSGPoint2f);
begin


end;

procedure TSGContextUnix.ShowCursor(const b:Boolean);
begin

end;

function TSGContextUnix.GetScreenResolution:TSGPoint2f;
begin

end;

function TSGContextUnix.GetCursorPosition:TSGPoint2f;
begin

end;

function TSGContextUnix.GetWindowRect:TSGPoint2f;
begin

end;

constructor TSGContextUnix.Create;
begin
inherited;

end;

destructor TSGContextUnix.Destroy;
begin

inherited;
end;

procedure TSGContextUnix.Initialize();
begin
Active:=CreateWindow();
if Active then
	begin
	if SGCLLoadProcedure<>nil then
		SGCLLoadProcedure(FSelfPoint);
	if FCallInitialize<>nil then
		FCallInitialize(FSelfPoint);
	end;
end;

procedure TSGContextUnix.Run;
var
	FDT:TSGDateTime;
begin
Messages;
FElapsedDateTime.Get;
while FActive and (FNewContextType=nil) do
	begin
	//Calc ElapsedTime
	FDT.Get;
	FElapsedTime:=(FDT-FElapsedDateTime).GetPastMiliSeconds;
	FElapsedDateTime:=FDT;
	
	Render.Clear(SGR_COLOR_BUFFER_BIT OR SGR_DEPTH_BUFFER_BIT);
	Render.InitMatrixMode(SG_3D);
	if FCallDraw<>nil then
		FCallDraw(FSelfPoint);
	//SGIIdleFunction;
	
	ClearKeys();
	Messages();
	
	if SGCLPaintProcedure<>nil then
		SGCLPaintProcedure(FSelfPoint);
	SwapBuffers();
	end;
end;

procedure TSGContextUnix.SwapBuffers();
begin
Render.SwapBuffers();
end;

procedure TSGContextUnix.Messages;
begin

inherited;
end;



function TSGContextUnix.CreateWindow():Boolean;
begin 

end;

procedure TSGContextUnix.InitFullscreen(const b:boolean); 
begin

inherited InitFullscreen(b);

end;

end.
