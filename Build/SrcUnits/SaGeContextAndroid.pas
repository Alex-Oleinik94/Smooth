{$INCLUDE Includes\SaGe.inc}
unit SaGeContextAndroid;
interface

uses 
	SaGeBase
	,SaGeBased
	,SaGeCommon
	,SaGeRender
	,SaGeContext
	,unix
	
	;
type
	TSGContextAndroid=class(TSGContext)
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
			public
		
		function  CreateWindow():Boolean;
			public
		function Get(const What:string):Pointer;override;
		end;
implementation

function TSGContextAndroid.Get(const What:string):Pointer;
begin
//if What='WINDOW HANDLE' then
//else if What='DESCTOP WINDOW HANDLE' then
//else if What = 'VISUAL INFO' then
end;

procedure TSGContextAndroid.SetCursorPosition(const a:TSGPoint2f);
begin


end;

procedure TSGContextAndroid.ShowCursor(const b:Boolean);
begin

end;

function TSGContextAndroid.GetScreenResolution:TSGPoint2f;
begin

end;

function TSGContextAndroid.GetCursorPosition:TSGPoint2f;
begin

end;

function TSGContextAndroid.GetWindowRect():TSGPoint2f;
begin
Result.Import();
end;

constructor TSGContextAndroid.Create();
begin
inherited;

end;

destructor TSGContextAndroid.Destroy();
begin

inherited;
end;

procedure TSGContextAndroid.Initialize();
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

procedure TSGContextAndroid.Run;
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

procedure TSGContextAndroid.SwapBuffers();
begin
Render.SwapBuffers();
end;

procedure TSGContextAndroid.Messages();
begin

inherited;
end;



function TSGContextAndroid.CreateWindow():Boolean;
begin

end;

procedure TSGContextAndroid.InitFullscreen(const b:boolean); 
begin

inherited InitFullscreen(b);

end;

end.
