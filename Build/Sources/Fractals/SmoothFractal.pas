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
	
	TSFractalData = class
			public
		constructor Create(const Fractal:TSFractal; const ThreadID:LongWord);
			public
		FThreadID:LongWord;
		FFractal:TSFractal;
		end;
	
	TSFractal = class(TSPaintableObject)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
			public
		FDepth:LongInt;
		
		FThreadsEnable:Boolean;
		
		FThreadsData:packed array of 
			packed record
				FFinished:Boolean;
				FData:TSFractalData;
				FThread:TSThread;
				end;
		
			public
		function ThreadsReady():Boolean;virtual;
		procedure Construct();virtual;
		procedure Paint();override;
		procedure CreateThreads(const a:Byte);virtual;
		procedure ThreadsBoolean(const b:boolean = false);virtual;
		procedure DestroyThreads();virtual;
		procedure AfterConstruct();virtual;
		procedure BeginConstruct();virtual;
		procedure SetThreadsQuantity(NewQuantity:LongWord);
		function GetThreadsQuantity():LongWord;inline;
			protected
		procedure SetDepth(const _Depth : LongInt); virtual;
			public
		property Depth:LongInt read FDepth write SetDepth;
		property ThreadsEnable:Boolean read FThreadsEnable write FThreadsEnable;
		property Threads:LongWord read GetThreadsQuantity write SetThreadsQuantity;
		end;

implementation

procedure TSFractal.SetDepth(const _Depth : LongInt);
begin
FDepth := _Depth;
end;

class function TSFractal.ClassName:string;
begin
Result := 'Smooth fractal';
end;

constructor TSFractalData.Create(const Fractal:TSFractal; const ThreadID:LongWord);
begin
inherited Create();
FFractal:=Fractal;
FThreadID:=ThreadID;
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
	begin
	if FThreadsData[i].FData<>nil then
		begin
		FThreadsData[i].FData.Destroy();
		FThreadsData[i].FData:=nil;
		end;
	if FThreadsData[i].FThread<>nil then
		begin
		FThreadsData[i].FThread.Destroy();
		FThreadsData[i].FThread:=nil;
		end;
	end;
SetLength(FThreadsData,0);
FThreadsData:=nil;
end;

procedure TSFractal.ThreadsBoolean(const b:boolean = false);
var
	i:LongInt;
begin
for i:=0 to High(FThreadsData) do
	begin
	FThreadsData[i].FFinished:=b;
	if FThreadsData[i].FData<>nil then
		begin
		FThreadsData[i].FData.Destroy;
		FThreadsData[i].FData:=Nil;
		end;
	FThreadsData[i].FFinished:=b;
	end;
end;

function TSFractal.ThreadsReady:Boolean;
var
	i:LongInt;
begin
Result:=True;
for i:=0 to High(FThreadsData) do
	if FThreadsData[i].FFinished=False then
		begin
		Result:=False;
		Break;
		end;
end;

procedure TSFractal.CreateThreads(const a:Byte);
var
	i:LongInt;
begin
SetLEngth(FThreadsData,a);
for i:=0 to High(FThreadsData) do
	FThreadsData[i].FData:=nil;
ThreadsBoolean(False);
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
SetLength(FThreadsData,NewQuantity);
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

destructor TSFractal.Destroy;
begin
DestroyThreads;
inherited;
end;

end.
