{$INCLUDE Smooth.inc}

unit SmoothFractal;

interface

uses 
	 SmoothBase
	,SmoothContextClasses
	,SmoothThreads
	;
type
	TSFractal = class;
	PSCustomFractalThreadData = ^ TSCustomFractalThreadData;
	
	TSFractalThreadData = object
			public
		procedure Clear(const _Fractal : TSFractal);
			private
		FThreadID:LongWord;
		FFractal:TSFractal;
		FThread:TSThread;
		FFinished:Boolean;
		FData : PSCustomFractalThreadData;
			public
		procedure FreeMemData();
		procedure KillThread();
			public
		property Fractal : TSFractal read FFractal write FFractal;
		property Finished : TSBoolean read FFinished write FFinished;
		property Data : PSCustomFractalThreadData read FData write FData;
		property Thread : TSThread read FThread write FThread;
		end;
	PSFractalThreadData = ^ TSFractalThreadData;
	TSFractalThreadDataList = packed array of TSFractalThreadData;
	
	TSCustomFractalThreadData = object
			private
		FFractalThreadData : PSFractalThreadData;
			public
		property FractalThreadData : PSFractalThreadData read FFractalThreadData write FFractalThreadData;
		end;
	
	TSFractal = class(TSPaintableObject)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
			protected
		FDepth:LongInt;
		FThreadsEnable:Boolean;
		FThreadsData : TSFractalThreadDataList;
			protected
		procedure SetDepth(const _Depth : LongInt); virtual;
		procedure SetThreadsQuantity(NewQuantity:LongWord);
		function GetThreadsQuantity():LongWord;inline;
		function GetThreadData(Index : TSMaxEnum) : PSFractalThreadData;
			public
		function ThreadsReady():Boolean;virtual;
		procedure Construct();virtual;
		procedure Paint();override;
		procedure CreateThreads(const a:Byte);virtual;
		procedure ThreadsBoolean(const b:boolean = false);virtual;
		procedure DestroyThreads();virtual;
		procedure AfterConstruct();virtual;
		procedure BeginConstruct();virtual;
			public
		property Depth:LongInt read FDepth write SetDepth;
		property ThreadsEnable:Boolean read FThreadsEnable write FThreadsEnable;
		property Threads:LongWord read GetThreadsQuantity write SetThreadsQuantity;
		property ThreadData[Index : TSMaxEnum] : PSFractalThreadData read GetThreadData;
		end;

procedure SKill(var _Object : PSCustomFractalThreadData); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
procedure SKill(var _Object : PSFractalThreadData); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
procedure SKill(var _Object : TSFractal); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

procedure SKill(var _Object : TSFractal); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if _Object <> nil then
	begin
	_Object.Destroy();
	_Object := nil;
	end;
end;

procedure SKill(var _Object : PSCustomFractalThreadData); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if _Object <> nil then
	begin
	FreeMem(_Object);
	_Object := nil;
	end;
end;

procedure SKill(var _Object : PSFractalThreadData); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if _Object <> nil then
	begin
	FreeMem(_Object);
	_Object := nil;
	end;
end;

// TSFractalThreadData

procedure TSFractalThreadData.FreeMemData();
begin
SKill(FData);
end;

procedure TSFractalThreadData.KillThread();
begin
SKill(FThread);
end;

procedure TSFractalThreadData.Clear(const _Fractal : TSFractal);
begin
FThreadID := 0;
FFractal := _Fractal;
FThread := nil;
FFinished := False;
end;

// TSFractal

function TSFractal.GetThreadData(Index : TSMaxEnum) : PSFractalThreadData;
begin
Result := @FThreadsData[Index];
end;

procedure TSFractal.SetDepth(const _Depth : LongInt);
begin
FDepth := _Depth;
end;

class function TSFractal.ClassName:string;
begin
Result := 'Smooth fractal';
end;

procedure TSFractal.AfterConstruct(); 
begin 
end;

procedure TSFractal.BeginConstruct(); 
begin 
end;

procedure TSFractal.DestroyThreads();
var
	i:LongInt;
begin
for i:=0 to High(FThreadsData) do
	SKill(FThreadsData[i].FThread);
SetLength(FThreadsData,0);
FThreadsData:=nil;
end;

procedure TSFractal.ThreadsBoolean(const b:boolean = false);
var
	i:LongInt;
begin
for i:=0 to High(FThreadsData) do
	FThreadsData[i].FFinished:=b;
end;

function TSFractal.ThreadsReady:Boolean;
var
	i:LongInt;
begin
Result:=True;
for i:=0 to High(FThreadsData) do
	if not FThreadsData[i].FFinished then
		begin
		Result:=False;
		Break;
		end;
end;

procedure TSFractal.CreateThreads(const a:Byte);
var
	i:LongInt;
begin
DestroyThreads();
if a > 0 then
	begin
	SetLength(FThreadsData,a);
	for i:=0 to High(FThreadsData) do
		FThreadsData[i].Clear(Self);
	end;
end;

procedure TSFractal.Paint();
begin
Render.Color3f(1,1,1);
end;

procedure TSFractal.Construct();
begin
end;

procedure TSFractal.SetThreadsQuantity(NewQuantity:LongWord);inline;
begin
CreateThreads(NewQuantity);
FThreadsEnable:=NewQuantity>0;
end;

function TSFractal.GetThreadsQuantity():LongWord;inline;
begin
Result:=Length(FThreadsData);
end;

constructor TSFractal.Create();
begin
inherited;
FDepth:=3;
FThreadsEnable:=False;
FThreadsData:=nil;
end;

destructor TSFractal.Destroy();
begin
DestroyThreads;
inherited;
end;

end.
