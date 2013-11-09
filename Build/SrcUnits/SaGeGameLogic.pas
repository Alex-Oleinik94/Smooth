{$i SaGe.inc}
unit SaGeGameLogic;

interface

uses
	SaGeCommon
	,SaGeBase, SaGeBased
	,SaGeMesh
	,crt
	,SaGeNet
	,gl
	,SaGeCL
	,Classes
	;

type
	TSGNGIdentifity=type SGByte;
	TSGNGInt = type int64;
	
	(**){ TSGGavmeBaseObject }(**)
	
	TSGGameBaseObject=class;
	TSGGameBaseObjectClass=class of TSGGameBaseObject;
	
	
	TSGGameMesh=class;
	TSGGameMeshClass=class of TSGGameMesh;
	
	TSGGameActor=class;
	TSGGameActorClass=class of TSGGameActor;
	
	TSGGameBaseObject=class
			public
		constructor Create;
		destructor Destroy;override;
			public
		FMustDie:boolean;
		FName:string;
		FPosition:TSGVertex;
		FScale:Single;
		FRotation:Single;
		FNRotation:Single;
		FIO:SGIdentityObject;
		FMainActor:Boolean;
			public
		procedure SetPosition(APosition:TSGVertex3f);
		procedure SetScale(AScale:Single);
		procedure SetRotation(ARotation:Single;AO:byte);
		procedure CheckMustDie;
			public
		property Position:TSGVertex write SetPosition;
		property Scale:single write SetScale;
			public
		procedure Draw;virtual;
		procedure Update(const AMiliSeconds:int64);virtual;
		procedure LoadFromFile(Name:String);virtual;
		procedure SaveToFile(Name:String);virtual;
		procedure Assign(AObj:TSGGameBaseObject);virtual;
		procedure Transfomtation;virtual;
		procedure TransfomtationForMap;virtual;
		procedure TransfomtationForNet;virtual;
			public
		property MustDie:boolean read FMustDie write FMustDie;
		property Name:string read FName write FName;
			public
		function AsGameMesh:TSGGameMesh;
		function AsGameActor:TSGGameActor;
		end;
	PSGGameBaseObject=^TSGGameBaseObject;

	(**){ TSGGameMesh }(**)

	TSGGameMesh=class(TSGGameBaseObject)
			public
		constructor Create;
		destructor Destroy;override;
			public
		FReady:Boolean;
		FMesh:TSGModel;
		FNeedToLoad:Boolean;
		FWay:string;
			public
		procedure Draw;override;
		procedure Update(const AMiliSeconds:int64);override;
		procedure LoadFromFile(FileName:String);override;
		procedure SaveToFile(FileName:String);override;
		procedure Assign(AObj:TSGGameBaseObject);override;
		procedure AssignFile(const AFile:String);
		procedure Loading;
			public
		property Ready:Boolean read FReady;
		property Way:string read FWay;
		property NeedToLoad:boolean read FNeedToLoad;
		end;
	PSGGameMesh=^TSGGameMesh;

	(**){ TSGGameActor }(**)

	TSGGameActor = class(TSGGameMesh)
			public
		constructor Create; 
		destructor Destroy; override;
			public
		FVelocity:single;
		FVelocityNormal:TSGVertex;
			public
		procedure Draw;override;
		procedure Update(const AMiliSeconds:int64);override;
		procedure LoadFromFile(FileName:String);override;
		procedure SaveToFile(FileName:String);override;
		procedure Assign(AObj:TSGGameBaseObject);override;
		procedure Transfomtation;override;
		end;
	PSGGameActor=^TSGGameActor;
	
	TSGMotoBike=class(TSGGameActor)
			public
		constructor Create;
		destructor Destroy;override;
			public
		FTailEnable:Boolean;
		FTails:
			packed array of
				packed array of
					TSGVertex3f;
		
		FClientAllTails:LongWord; 				// Send Server -> Client , and client save it
		FClientLastTailLength:LongWord; 		// Send Server -> Client , and client save it
		FClientTailLoad:LongWord; 				// posotion on client
		FClientTailLoadPosition:LongWord; 		// position on server
		
		FWayConfig:string;
		FNickName:String;
		FBikeColor,FTailColor:TSGColor4f;
		
		FReadyToPlay:Boolean;
		
		procedure SavePlayerConfig;inline;
		procedure LoadPlayerConfig;inline;
		
		procedure Draw;override;
		procedure UpDate(const AMiliSeconds:int64);override;
		procedure DrawTails;virtual;
		procedure SetTailEnable(const AET:Boolean);
			public
		property TailEnable:boolean read FTailEnable write SetTailEnable;
		end;
	
	(**){ TSGNetActor }(**)
	
	TSGNetActor= class(TSGMotoBike)
			public
		constructor Create; 
		destructor Destroy; override;
			public
		FIdentifity:TSGNGInt;
			public
		property Identifity:TSGNGInt read FIdentifity write FIdentifity;
		end;
	
	(**){ TSGGame }(**)
	
	
	TSGGame = class
			public
		constructor Create;
		destructor Destroy;override;
			public
		FDataTime:TSGDateTime;
		FThread:TSGThread;
		FLoadingThread:TSGThread;
		FOnlyLoading:boolean;
		FMainActor:TSGMotoBike;
		FMap:packed array of TSGGameMesh;
		FNetPlayers:packed array of TSGNetActor;
		FNetPlayersLength:TSGNGInt;
		FConnection:TSGUDPConnection;
		FNextNumberClient:TSGNGInt;
		FNumberClient:TSGNGInt;
		FLoadingProgressBar:TSGProgressBar;
		FUseThread:Boolean;
			public
		procedure Draw;virtual;
		procedure UpDate(const AMiliSeconds:int64);virtual;
		procedure StartThread;
		procedure Execute;virtual;
		procedure AddMapMesh(const AClass:TSGGameMeshClass;const FileWay:string = '');inline;
		procedure AddMainActor(const AClass:TSGMotoBike;const FileWay:string = '');inline;
		procedure Receive(const AStream:TMemoryStream; const aSocket: TSGSocket);inline;
		procedure CreateConnection;inline;
		procedure DestroyConnection;inline;
		procedure DestroyNetPlayers;
		procedure Loading;
		procedure CallAction;inline;
		procedure StartConnection;inline;
		procedure StartGame;inline;
			public
		property ConnectionMode:TSGConnectionMode read FConnection.FConnectionMode write FConnection.FConnectionMode;
		property Connection : TSGUDPConnection read FConnection;
		property LoadingProgressBar : TSGProgressBar read FLoadingProgressBar write FLoadingProgressBar;
		property OnlyLoading : boolean read FOnlyLoading write FOnlyLoading;
		property UseThread : boolean read FUseThread write FUseThread;
		end;
const
	SGNGNeedCreate =            $000000;
	SGNGCreate =                $000001;
	SGNGNeedCallAction =        $000002;
	SGNGCallAction =            $000003;
	SGNGDestroy =               $000004;
	
	SGNGCanPlay =               $000005;
	SGNGNeedCanPlay =           $000006;
implementation

	(**){ TSGMotoBike }(**)

procedure TSGMotoBike.SavePlayerConfig;inline;
var
	Stream:TFileStream = nil;
begin
Stream:=TFileStream.Create(FWayConfig,fmCreate);
SGWriteStringToStream(FNickName,Stream);
FBikeColor.WriteToStream(Stream);
FTailColor.WriteToStream(Stream);
Stream.Destroy;
end;

procedure TSGMotoBike.LoadPlayerConfig;inline;
var
	Stream:TFileStream = nil;
begin
if SGFileExists(FWayConfig) then
	begin
	Stream:=TFileStream.Create(FWayConfig,fmOpenRead);
	FNickName:=SGReadStringFromStream(Stream);
	FBikeColor.ReadFromStream(Stream);
	FTailColor.ReadFromStream(Stream);
	Stream.Destroy;
	end
else
	begin
	FNickName:='Default';
	FTailColor.Import(1,0.5,0.25,0.3);
	FBikeColor.Import(1,1,1,1);
	
	SavePlayerConfig;
	end;
end;

procedure TSGMotoBike.Draw;
begin
FMesh.FObjectColor:=FBikeColor;
inherited;
end;

constructor TSGMotoBike.Create; 
begin
inherited;
FTailEnable:=False;
FTails:=nil;
FMainActor:=False;
FWayConfig:='TronConfig.cfg';
LoadPlayerConfig;
FReadyToPlay:=False;
end;

destructor TSGMotoBike.Destroy;
var
	i:LongInt;
begin
for i:=0 to High(FTails) do
	SetLength(FTails[i],0);
SetLength(FTails,0);
inherited;
end;

procedure TSGMotoBike.DrawTails;
var
	i,ii:LongInt;
begin
FTailColor.Color;
glBegin(GL_QUADS);
for i:=0 to High(FTails) do
	begin
	for ii:=1 to High(FTails[i]) do
		begin
		SGGetVertexWhichNormalFromThreeVertex(
			FTails[i][ii],
			FTails[i][ii-1],
			(FTails[i][ii-1]+SGY(1))).Normal;
		FTails[i][ii].Vertex;
		FTails[i][ii-1].Vertex;
		(FTails[i][ii-1]+SGY(1)).Vertex;
		(FTails[i][ii]+SGY(1)).Vertex;
		end;
	end;
glEnd();
end;

procedure TSGMotoBike.SetTailEnable(const AET:Boolean);
begin
if (not FTailEnable) AND (AET) then
	begin
	SetLength(FTails,Length(FTails)+1);
	SetLength(FTails[High(FTails)],1);
	FTails[High(FTails)][High(FTails[High(FTails)])]:=-((FPosition-1.5*SGVertexImport(cos(FRotation/180*pi),0,sin(FRotation/180*pi))));
	end;
FTailEnable:=AET;
end;

procedure TSGMotoBike.UpDate(const AMiliSeconds:int64);
const
	Const1 = 0.1;
	Const2 = 1.5;
begin
inherited UpDate(AMiliSeconds);
if FMainActor then
	begin
	if SGIsKeyDown('W') or SGIsKeyDown('w') then
		FVelocity+=0.002*AMiliSeconds/100*60
	else
		if FVelocity>0.002*AMiliSeconds/100*60 then
			FVelocity-=0.002*AMiliSeconds/100*60;

	if SGIsKeyDown('S') or SGIsKeyDown('s') then
		FVelocity/=1.015**AMiliSeconds;

	if SGIsKeyDown('A') or SGIsKeyDown('a') then
		begin
		if FVelocity<Const1 then
			FRotation-=Const2*AMiliSeconds*(FVelocity/Const1)
		else
			FRotation-=Const2*AMiliSeconds;
		end;
	if SGIsKeyDown('D') or SGIsKeyDown('d') then
		begin
		if FVelocity<Const1 then
			FRotation+=Const2*AMiliSeconds*(FVelocity/Const1)
		else
			FRotation+=Const2*AMiliSeconds;
		end;
	if (SGKeyPressedChar='Q') or (SGKeyPressedChar='q') then
		begin
		SGKeyPressedVariable:=#0;
		TailEnable:= not TailEnable;
		end;
	end;
if FTailEnable then
	begin
	if SGAbsTwoVertex(-(FPosition-1.5*SGVertexImport(cos(FRotation/180*pi),0,sin(FRotation/180*pi))),FTails[High(FTails)][High(FTails[High(FTails)])])>0.2 then
		begin
		SetLength(FTails[High(FTails)],Length(FTails[High(FTails)])+1);
		FTails[High(FTails)][High(FTails[High(FTails)])]:=-(FPosition-1.5*SGVertexImport(cos(FRotation/180*pi),0,sin(FRotation/180*pi)));
		end;
	end;
end;

	(**){ TSGNetActor }(**)

constructor TSGNetActor.Create; 
begin
inherited;
FIdentifity:=-2;
FReady:=True;
end;

destructor TSGNetActor.Destroy;
begin
inherited;
end;

	(**){ TSGGameMesh }(**)

procedure TSGGameMesh.Loading;
begin
LoadFromFile(FWay);
FNeedToLoad:=False;
end;

procedure TSGGameMesh.AssignFile(const AFile:String);
begin
FWay:=AFile;
FNeedToLoad:=True;
end;

constructor TSGGameMesh.Create;
begin
inherited Create;
FReady:=False;
FMesh:=nil;
FNeedToLoad:=False;
FWay:='';
end;

destructor TSGGameMesh.Destroy;
begin
inherited Destroy;
end;

procedure TSGGameMesh.Draw;
begin
inherited Draw;
if Ready then
	FMesh.Draw;
end;

procedure TSGGameMesh.Update(const AMiliSeconds:int64);
begin
inherited Update(AMiliSeconds);
end;

procedure TSGGameMesh.LoadFromFile(FileName: String);
begin
inherited LoadFromFile(FileName);
FMesh:=TSGModel.Create;
FMesh.LoadFromFile(FileName);
FReady:=True;
end;

procedure TSGGameMesh.SaveToFile(FileName: String);
begin
  inherited SaveToFile(FileName);
end;

procedure TSGGameMesh.Assign(AObj: TSGGameBaseObject);
begin
  inherited Assign(AObj);
end;

	(**){ TSGGameBaseObject }(**)

procedure TSGGameBaseObject.Transfomtation;
begin
FIO.Init;
end;

function TSGGameBaseObject.AsGameMesh:TSGGameMesh;
begin
if Self is TSGGameMesh then
	Result:=TSGGameMesh(Pointer(Self))
else
	Result:=nil;
end;

function TSGGameBaseObject.AsGameActor:TSGGameActor;
begin
if Self is TSGGameActor then
	Result:=TSGGameActor(Pointer(Self))
else
	Result:=nil;
end;


constructor TSGGameBaseObject.Create;
begin
inherited Create;
FMustDie:=False;
FName:='';
FPosition.Import;
FScale:=1;
FRotation:=0;
FNRotation:=0;
FIO.Clear;
end;

destructor TSGGameBaseObject.Destroy;
begin
inherited Destroy;
end;

procedure TSGGameBaseObject.SetPosition(APosition: TSGVertex3f);
begin

end;

procedure TSGGameBaseObject.SetScale(AScale: single);
begin

end;

procedure TSGGameBaseObject.SetRotation(ARotation:Single;AO:byte);
begin

end;

procedure TSGGameBaseObject.CheckMustDie;
begin

end;

procedure TSGGameBaseObject.Draw;
begin
FIO.Change;
end;

procedure TSGGameBaseObject.Update(const AMiliSeconds:int64);
begin

end;

procedure TSGGameBaseObject.LoadFromFile(Name: String);
begin

end;

procedure TSGGameBaseObject.SaveToFile(Name: String);
begin

end;

procedure TSGGameBaseObject.Assign(AObj: TSGGameBaseObject);
begin

end;

procedure TSGGameBaseObject.TransfomtationForMap;
begin
Transfomtation;
glRotatef(FRotation,     0,1,0);
FPosition.Translate;
end;

procedure TSGGameBaseObject.TransfomtationForNet;
begin
(-FPosition).Translate;
glRotatef(360-FRotation,0,1,0);
end;

	(**){ TSGGameActor }(**)

procedure TSGGameActor.Transfomtation;
const 
	Const3 = 1;
	Const4 = 0.4;
begin
SGLookAt(
	SGVertexImport(
		cos(Const3*(FNRotation-FRotation)/180*pi),
		0,
		sin(Const3*(FNRotation-FRotation)/180*pi))
			*(
				6+
				Byte(FVelocity<Const4)*(FVelocity/Const4)*4+
				Byte(not(FVelocity<Const4))*4)+
				SGY(4),
	-SGVertexImport(cos(Const3*(FNRotation-FRotation)/180*pi),0,sin(Const3*(FNRotation-FRotation)/180*pi))*4,
	SGVertexImport(0,1,0));
end;

constructor TSGGameActor.Create;
begin
  inherited Create;
end;

destructor TSGGameActor.Destroy;
begin
  inherited Destroy;
end;

procedure TSGGameActor.Draw;
begin
inherited Draw;
end;

procedure TSGGameActor.Update(const AMiliSeconds:int64);
const
	Const1 = 40;
begin
inherited Update(AMiliSeconds);
FNRotation:=FNRotation*(0.95-AMiliSeconds/Const1)+FRotation*(0.05+AMiliSeconds/Const1);
FVelocityNormal:=SGVertexImport(cos(FNRotation/180*pi),0,sin(FNRotation/180*pi));
FPosition+=FVelocityNormal*FVelocity*AMiliSeconds*0.9;
end;

procedure TSGGameActor.LoadFromFile(FileName: String);
begin
inherited LoadFromFile(FileName);
end;

procedure TSGGameActor.SaveToFile(FileName: String);
begin
  inherited SaveToFile(FileName);
end;

procedure TSGGameActor.Assign(AObj: TSGGameBaseObject);
begin
  inherited Assign(AObj);
end;

	(**){TSGGame}(**)

procedure TSGGameStartThread(AClass:TSGGame);
begin
AClass.Execute;
end;

procedure TSGGameStartLoadingThread(AClass:TSGGame);
begin
AClass.Loading;
end;

procedure TSGGameReceive(AClass:TSGGame;AStream:TMemoryStream; aSocket: TSGSocket);
begin
AClass.Receive(AStream,ASocket);
end;

constructor TSGGame.Create;
begin
inherited Create;
FMainActor:=nil;
FMap:=nil;
FNetPlayers:=nil;
FThread:=nil;
FLoadingThread:=nil;
FLoadingThread:=TSGThread.Create(TSGThreadProcedure(@TSGGameStartLoadingThread),Self,False);
FThread:=TSGThread.Create(TSGThreadProcedure(@TSGGameStartThread),Self,False);
FDataTime.Clear;
FNumberClient:=-2;
FNextNumberClient:=0;
CreateConnection;
FLoadingProgressBar:=nil;
FNetPlayersLength:=0;
FOnlyLoading:=False;
FUseThread:=True;
end;

procedure TSGGame.CreateConnection;inline;
begin
FConnection:=TSGUDPConnection.Create;
FConnection.Parent:=Self;
FConnection.ReceiveProcedure:=TSGReceiveProcedure(@TSGGameReceive);
end;

procedure TSGGame.DestroyConnection;inline;
var
	OldConnection:TSGUDPConnection = nil;
begin
OldConnection:=FConnection;
FConnection:=nil;
OldConnection.Destroy;
end;

procedure TSGGame.DestroyNetPlayers;
var
   i:LongInt;
begin
for i:=0 to High(FNetPlayers) do
    FNetPlayers[i].Destroy;
SetLength(FNetPlayers,0);
FNetPlayers:=nil;
FNetPlayersLength:=0;
end;

destructor TSGGame.Destroy;
var
   i:LongInt;
begin
for i:=0 to High(FMap) do
    FMap[i].Destroy;
SetLength(FMap,0);
FMap:=nil;
DestroyNetPlayers;
FMainActor.Destroy;
FMainActor:=nil;
if FThread<>nil then
	FThread.Destroy;
if FLoadingThread<>nil then
	FLoadingThread.Destroy;
inherited Destroy;
end;

procedure TSGGame.Draw;
var
	i:LongInt;
begin
if OnlyLoading then
	Exit;
if not FUseThread then
	CallAction;
SGInitMatrixMode(SG_3D);
if (FMainActor<>nil) then
	FMainActor.TransfomtationForMap;
for i:=0 to High(FMap) do
	if FMap[i].Ready then
		FMap[i].Draw;
if (FMainActor<>nil) and (FMainActor is TSGMotoBike)then
	begin
	TSGMotoBike(Pointer(FMainActor)).DrawTails;
	end;
for i:=0 to FNetPlayersLength-1 do
	begin
	FNetPlayers[i].DrawTails;
	end;
glLoadIdentity;
if (FMainActor<>nil) then
	begin
	FMainActor.Transfomtation;
	if FMainActor.Ready then
		FMainActor.Draw;
	end;
for i:=0 to FNetPlayersLength-1 do
	begin
	glLoadIdentity;
	if (FMainActor<>nil) then
		FMainActor.TransfomtationForMap;
	FNetPlayers[i].TransfomtationForNet;
	FNetPlayers[i].Draw;
	end;
end;

procedure TSGGame.UpDate(const AMiliSeconds:int64);
var
	i:LongInt;
begin
if AMiliSeconds>0 then
	begin
	FMainActor.UpDate(AMiliSeconds);
	for i:=0 to high(FMap) do
		FMap[i].UpDate(AMiliSeconds);
	for i:=0 to High(FNetPlayers) do
		FNetPlayers[i].UpDate(AMiliSeconds);
	end;
end;

procedure TSGGame.Loading;
var
	i,j:LongInt;
begin
j:=0;
if (FMainActor<>nil) and (FMainActor.NeedToLoad) then
	j+=1;
j+=Length(FMap);
if (FLoadingProgressBar<>nil)  then
	FLoadingProgressBar.FNeedProgress:=0;
if (FMainActor<>nil) and (FMainActor.NeedToLoad) then
	FMainActor.Loading;
if (FLoadingProgressBar<>nil)  then
	FLoadingProgressBar.FNeedProgress:=1/j;
for i:=0 to High(FMap) do
	if (FMap[i] is TSGGameMesh) and (FMap[i].AsGameMesh.NeedToLoad) then
		begin
		FMap[i].AsGameMesh.Loading;
		if (FLoadingProgressBar<>nil)  then
			FLoadingProgressBar.FNeedProgress:=(1+i+1)/j;
		end;
if (FLoadingProgressBar<>nil)  then
	FLoadingProgressBar.Visible:=False;
end;

procedure TSGGame.CallAction;inline;
var
	Date:TSGDateTime;
begin
Date.Get;
UpDate((Date-FDataTime).GetPastMiliSeconds);
FDataTime:=Date;
if FConnection<>nil then
	FConnection.CallAction;
end;

procedure TSGGame.StartConnection;inline;

procedure SendNGNeedCreate(const AConnection:TSGUDPConnection);inline;
var
	Stream:TMemoryStream = nil;
	Identifity:TSGNGIdentifity = SGNGNeedCreate;
begin
Stream:=TMemoryStream.Create;
Stream.WriteBuffer(Identifity,SizeOf(Identifity));
SGWriteStringToStream(FMainActor.FNickName,Stream);
AConnection.SendMemoryStream(Stream);
Stream.Destroy;
end;

begin
FConnection.Start;
if ConnectionMode=TSGClientMode then
	SendNGNeedCreate(FConnection);
end;

procedure TSGGame.StartGame;inline;
begin
StartConnection;
FOnlyLoading:=False;
if FUseThread then
	FThread.Start;
end;

{$NOTE EXECUTE}
procedure TSGGame.Execute;
begin
while FOnlyLoading do
	Delay(100);
while not FOnlyLoading do
	begin
	CallAction;
	Delay(0);
	end;
end;

procedure TSGGame.Receive(const AStream:TMemoryStream; const aSocket: TSGSocket);
var
	Identifity:TSGNGIdentifity = 0;
	Id:TSGNGIdentifity;
	Int,Int2:TSGNGInt;
	Stream:TMemoryStream = nil;
	i,ii:LongInt;
	Bool:Boolean;

procedure ReadInfo(const ARStream:TMemoryStream;const AActor:TSGMotoBike);inline;
var
	TE:Boolean;
begin
ARStream.ReadBuffer(AActor.FPosition,SizeOf(AActor.FPosition));
ARStream.ReadBuffer(AActor.FScale,SizeOf(AActor.FScale));
ARStream.ReadBuffer(AActor.FRotation,SizeOf(AActor.FRotation));
ARStream.ReadBuffer(AActor.FVelocity,SizeOf(AActor.FVelocity));
ARStream.ReadBuffer(AActor.FVelocityNormal,SizeOf(AActor.FVelocityNormal));
ARStream.ReadBuffer(TE,SizeOf(TE));
AActor.TailEnable:=TE;
end;

procedure WriteInfo(const AWStream:TMemoryStream;const AActor:TSGMotoBike);inline;
begin
AWStream.WriteBuffer(AActor.FPosition,SizeOf(AActor.FPosition));
AWStream.WriteBuffer(AActor.FScale,SizeOf(AActor.FScale));
AWStream.WriteBuffer(AActor.FRotation,SizeOf(AActor.FRotation));
AWStream.WriteBuffer(AActor.FVelocity,SizeOf(AActor.FVelocity));
AWStream.WriteBuffer(AActor.FVelocityNormal,SizeOf(AActor.FVelocityNormal));
AWStream.WriteBuffer(AActor.FTailEnable,SizeOf(AActor.FTailEnable));
end;

procedure SendNeedCallAction;inline;
begin
Stream:=TMemoryStream.Create;
Id:=SGNGNeedCallAction;
Stream.WriteBuffer(Id,SizeOf(Id));
Stream.WriteBuffer(FNumberClient,SizeOf(FNumberClient));
WriteInfo(Stream,FMainActor);
FConnection.SendMemoryStream(Stream);
Stream.Destroy;
Stream:=nil;
end;

procedure SendCallAction(const NInt:TSGNGInt);
var
	j:LongInt;
begin
Stream:=TMemoryStream.Create;
Id:=SGNGCallAction;
Stream.WriteBuffer(Id,SizeOf(Id));
Int:=-1;
Stream.WriteBuffer(Int,SizeOf(Int));
WriteInfo(Stream,FMainActor);
for j:=0 to High(FNetPlayers) do
	begin
	if FNetPlayers[j].Identifity<>NInt then
		begin
		Stream.WriteBuffer(FNetPlayers[j].FIdentifity,SizeOf(FNetPlayers[j].FIdentifity));
		WriteInfo(Stream,FNetPlayers[j]);
		end;
	end;
Int:=-2;
Stream.WriteBuffer(Int,SizeOf(Int));
FConnection.SendMemoryStream(Stream);
Stream.Destroy;
Stream:=nil;
end;

procedure ReceiveCallAction;
var
	j,jj:LongInt;
	b:boolean;
begin
AStream.ReadBuffer(Int,SizeOf(Int));
while Int<>-2 do
	begin
	jj:=-2;
	for j:=0 to High(FNetPlayers) do
		if FNetPlayers[j].FIdentifity=Int then
			begin
			jj:=j;
			Break;
			end;
	b:=False;
	if jj=-2 then
		begin
		SetLength(FNetPlayers,Length(FNetPlayers)+1);
		FNetPlayers[High(FNetPlayers)]:=TSGNetActor.Create;
		FNetPlayers[High(FNetPlayers)].Identifity:=Int;
		FNetPlayers[High(FNetPlayers)].FMesh:=FMainActor.FMesh;
		
		jj:=High(FNetPlayers);
		b:=True;
		end;
	ReadInfo(AStream,FNetPlayers[jj]);
	if b then 
		FNetPlayersLength+=1;
	AStream.ReadBuffer(Int,SizeOf(Int));
	end;
end;

begin
if FOnlyLoading then
	Exit;
AStream.ReadBuffer(Identifity,SizeOf(Identifity));
case Identifity of
SGNGNeedCreate:
	begin
	if ConnectionMode = TSGServerMode then
		begin
		Stream:=TMemoryStream.Create;
		Id:=SGNGCreate;
		Stream.WriteBuffer(Id,SizeOf(Id));
		Int:=FNextNumberClient;
		FNextNumberClient+=1;
		Stream.WriteBuffer(Int,SizeOf(Int));
		
		SetLength(FNetPlayers,Length(FNetPlayers)+1);
		FNetPlayers[High(FNetPlayers)]:=TSGNetActor.Create;
		FNetPlayers[High(FNetPlayers)].Identifity:=Int;
		FNetPlayers[High(FNetPlayers)].FMesh:=FMainActor.FMesh;
		FNetPlayers[High(FNetPlayers)].FNickName:=
				SGReadStringFromStream(AStream);
		FNetPlayersLength+=1;
		
		FConnection.SendMemoryStream(Stream);
		Stream.Destroy;
		Stream:=nil;
		end;
	end;
SGNGCreate:
	begin
	if ConnectionMode=TSGClientMode then
		begin
		AStream.ReadBuffer(FNumberClient,SizeOf(FNumberClient));
		SendNeedCallAction;
		end;
	end;
SGNGNeedCallAction:
	begin
	if ConnectionMode=TSGServerMode then
		begin
		AStream.ReadBuffer(Int,SizeOf(Int));
		for i:=0 to High(FNetPlayers) do
			if FNetPlayers[i].Identifity=Int then
				begin
				ReadInfo(AStream,FNetPlayers[i]);
				Break;
				end;
		SendCallAction(Int);
		end;
	end;
SGNGCallAction:
	begin
	if ConnectionMode=TSGClientMode then
		begin
		ReceiveCallAction;
		SendNeedCallAction;
		end;
	end;
else
	begin
	
	end;
end;
end;

procedure TSGGame.AddMapMesh(const AClass:TSGGameMeshClass;const FileWay:string = '');inline;
begin
SetLength(FMap,Length(FMap)+1);
FMap[High(FMap)]:=AClass.Create;
if FileWay<>'' then
	FMap[High(FMap)].AssignFile(FileWay);
end;

procedure TSGGame.AddMainActor(const AClass:TSGMotoBike;const FileWay:string = '');inline;
begin
if FMainActor<>nil then
	FMainActor.Destroy;
FMainActor:=AClass;
if FileWay<>'' then
	FMainActor.AssignFile(FileWay);
FMainActor.FMainActor:=True;
end;

procedure TSGGame.StartThread;
begin
if FUseThread then
	FLoadingThread.Start
else
	Loading;
end;

begin
end.
