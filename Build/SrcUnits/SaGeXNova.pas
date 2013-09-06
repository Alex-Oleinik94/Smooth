{$I SaGe.inc}
unit SaGeXNova;
interface
uses 
	crt
	{$IFDEF MSWINDOWS}
		,windows
		{$ENDIF}
	{$IFDEF UNIX}
		,unix
		{$ENDIF}
	,SaGe
	,GL
	,SaGeCL
	,GLu
	,SaGeMath
	,SaGeBase
	,SaGeImagesBase
	,SysUtils
	,Classes
	,SaGeImagesPng
	,SaGeImagesBmp
	,SaGeFractals
	;
{Крысявичача}
const
	XNovaUnitSpase=1;
	XNovaUnitGround=2;
	XNovaUnitSpaseDefense=3;
	XNovaUnitGroundDefense=4;
	XNovaResourse=5;
	XNovaBuilding=6;
	XNovaValue=7;
type
	Int=int64;
	
	TSGXNovaObject=class;
	TSGXNovaObjectClass=class of TSGXNovaObject;
	TSGXNovaWorld=class;
	TSGXNovaUnitsDocumentation=class;
	TSGXNovaUnits=class;
	TSGXNovaBuildingsWaiting=class;
	
	TSGXNovaWaitingClass=class;
	TSGXNovaWaitingClasses=packed array of TSGXNovaWaitingClass;
	TSGXNovaWaitingClass=class
		FTime:Int;
		procedure Go(const Documentation:TSGXNovaUnitsDocumentation);virtual;abstract;
		end;
	TSGXNovaBuildingWaitingClass=class(TSGXNovaWaitingClass)
		FWaiting:TSGXNovaBuildingsWaiting;
		constructor Create(const Waiting:TSGXNovaBuildingsWaiting;const Time:Int);
		destructor Destroy;override;
		procedure Go(const Documentation:TSGXNovaUnitsDocumentation);override;
		end;
	
	TSGXNovaObject=class
		constructor Create;virtual;
		procedure Load(const Stream:TStream);virtual;abstract;overload;
		procedure Save(const Stream:TStream);virtual;abstract;overload;
		procedure GetWaiting(const Seconds:Int;var Waiting:TSGXNovaWaitingClasses;const Documentation:TSGXNovaUnitsDocumentation);virtual;
		procedure UpDate(const Documentation:TSGXNovaUnitsDocumentation);virtual;
		class function GetPolygonesFromDiametr(const Diamert:Int):Int;
		end;
	TSGXNovaUsers=class(TSGXNovaObject)
		FUsers:packed array of array[0..1] of string;
		constructor Create;override;
		destructor Destroy;override;
		procedure Load(const Stream:TStream);override;
		procedure Save(const Stream:TStream);override;
		end;
	TSGXNovaUnit=class(TSGXNovaObject)
		FIdentifity:Int;
		FQuantity:Int;
		constructor Create;override;
		destructor Destroy;override;
		procedure Load(const Stream:TStream);override;
		procedure Save(const Stream:TStream);override;
		end;
	TSGXNovaUnits=class(TSGXNovaObject)
		FUnits:packed array of TSGXNovaUnit;
		constructor Create;override;
		destructor Destroy;override;
		procedure Load(const Stream:TStream);override;
		procedure Save(const Stream:TStream);override;
		function FindUnit(const ID:Int):Int;
		procedure SetQuantityUnits(const ID,Quantity:Int);
		procedure IncUnit(const ID:Int;const Quantity:Int = 1);
		function UnitExists(const Identifity:Int):Boolean;
		end;
	TSGXNovaCoord=class(TSGXNovaObject)
		FGalaxy:Int;
		FSolarSystem:Int;
		FPosition:Int;
		FThat:Int;
		constructor Create;override;
		destructor Destroy;override;
		procedure Load(const Stream:TStream);override;
		procedure Save(const Stream:TStream);override;
		procedure CreateRandom;
		function ToPChar:PCHar;
		end;
	TSGXNovaBuildingsWaiting=class(TSGXNovaObject)
		FSeconds:Int;
		FWaiting:packed array of Int;
		FUnits:TSGXNovaUnits;
		constructor Create;override;
		destructor Destroy;override;
		procedure Load(const Stream:TStream);override;
		procedure Save(const Stream:TStream);override;
		procedure UpDate(const Documentation:TSGXNovaUnitsDocumentation);override;
		procedure GetWaiting(const Seconds:Int;var Waiting:TSGXNovaWaitingClasses;const Documentation:TSGXNovaUnitsDocumentation);override;
		procedure NewBuilding(const Identifity:Int;const Time:Int);inline;
		function GetNextBuildingLevel(const BuildingID:Int):Int;
		function GetBuildTime(const Identifity:Int;const Quantity:Int;const Documentation:TSGXNovaUnitsDocumentation;const PositionInWaiting:Int = -1):Int;
		function GetLvlWithWaiting(const WaitingId:Int; const Identifity:Int = -1):Int;
		end;
	TSGXNovaUserPlanet=class(TSGXNovaObject)
		FUser:String;
		FMainPlanet:Boolean;
		FUnits:TSGXNovaUnits;
		FBildingsWaiting:TSGXNovaBuildingsWaiting;
		constructor Create;override;
		destructor Destroy;override;
		procedure Load(const Stream:TStream);override;
		procedure Save(const Stream:TStream);override;
		procedure UpDate(const Documentation:TSGXNovaUnitsDocumentation);override;
		end;
	TSGXNovaPlanet=class(TSGXNovaObject)
		FCoord:TSGXNovaCoord;
		FName:String;
		FDiametr:Int;
		FPolygones:Int;
		FNumberPicture:Int;
		FUserPlanets:packed array of TSGXNovaUserPlanet;
		constructor Create;override;
		destructor Destroy;override;
		procedure Load(const Stream:TStream);override;
		procedure Save(const Stream:TStream);override;
		procedure UpDate(const Documentation:TSGXNovaUnitsDocumentation);override;
		procedure CreateRandom(const User:String; const Documentation:TSGXNovaUnitsDocumentation = nil);
		function UserExists(const User:String):Boolean;
		function BusyPoligones(const Documentation:TSGXNovaUnitsDocumentation):Int;
		function GetUserPlanet(const User:string):TSGXNovaUserPlanet;
		end;
	TSGXNovaFeet=class(TSGXNovaObject)
		FUserName:String;
		FDateTime:TSGDateTime;
		FCoord1:TSGXNovaCoord;
		FCoord2:TSGXNovaCoord;
		FMission:Int;
		FUnits:TSGXNovaUnits;
		FResourses:TSGXNovaUnits;
		constructor Create;override; 
		destructor Destroy;override;
		procedure Load(const Stream:TStream);override;
		procedure Save(const Stream:TStream);override;
		end;
	TSGXNovaFeets=class(TSGXNovaObject)
		FFleets:packed array of TSGXNovaFeet;
		constructor Create;override;
		destructor Destroy;override;
		procedure Load(const Stream:TStream);override;
		procedure Save(const Stream:TStream);override;
		end;
	TSGXNovaPlanets=class(TSGXNovaObject)
		FPlanets:packed array of TSGXNovaPlanet;
		procedure UpDate(const Documentation:TSGXNovaUnitsDocumentation);override;
		procedure GetWaiting(const Seconds:Int;var Waiting:TSGXNovaWaitingClasses;const Documentation:TSGXNovaUnitsDocumentation);override;
		constructor Create;override;
		destructor Destroy;override;
		procedure Load(const Stream:TStream);override;
		procedure Save(const Stream:TStream);override;
		end;
	TSGXNovaUnitDocumentation=class
		FType:Int;
		FName:String;
		FCapture:String;
		FPicture:TSGGLImage;
		FPrice:packed array of
				packed record
					FLvl:Int;
					FIdentifity:Int;
					FValue:Int;
					FProcent:Int;
					end;
		FMining:packed array of
			packed record
				FIdentifity:Int;
				FMining:Int;
				FProcent:Int;
				end;
		
		FBuildTime:Int;
		FBuildTimeProcent:Int;
		
		FUnMiningResourse:Boolean;
		
		FDecBuildTime:Int;
		FDecBuildTimeProcent:Int;
		
		FStartQuantity:Int;
		constructor Create;
		procedure Load(const TextFile:PText);
		procedure Load(const FileName:String);
		end;
	TSGXNovaUnitsDocumentation=class
		FDocumentation:packed array of TSGXNovaUnitDocumentation;
		procedure Load(const FileName:String);
		procedure LoadImages;
		end;
	TSGXNovaWorld=class(TSGXNovaObject)
		FDateTime:TSGDateTime;
		FUsers:TSGXNovaUsers;
		FFleets:TSGXNovaFeets;
		FPlanets:TSGXNovaPlanets;
		constructor Create;override;
		destructor Destroy;override;
		procedure Load(const Stream:TStream);override;overload;
		procedure Save(const Stream:TStream);override;overload;
		procedure UpDate(const Seconds:Int;const Documentation:TSGXNovaUnitsDocumentation);overload;
		procedure CreateNewUser(const NewUser,NewPassword:String; const Documentation:TSGXNovaUnitsDocumentation = nil);
		function VerificationPassword(const User,Password:String):Boolean;
		function GetPlanet(const User:String;const Number:LongInt):TSGXNovaPlanet;
		class function GetResQuantity(Res1Lvl:Extended;const Procent:Int;const Lvl:Int):Int;
		class function SGXNovaCoordsEqual(const a,b:TSGXNovaCoord):Boolean;
		function UserExists(const User:String):Boolean;
		procedure Load(const FileName:String);overload;
		end;

implementation

procedure TSGXNovaWorld.Load(const FileName:String);overload;
var
	Stream:TMemoryStream = nil;
begin
Stream:=TMemoryStream.Create;
Stream.LoadFromFile(FileName);
Self.Load(Stream);
Stream.Destroy;
end;

function TSGXNovaWorld.UserExists(const User:String):Boolean;
var
	i:LongInt;
begin
Result:=False;
for i:=0 to High(FUsers.FUsers) do
	if FUsers.FUsers[i][0]=User then
		begin
		Result:=True;
		Break;
		end;
end;

function TSGXNovaUnits.UnitExists(const Identifity:Int):Boolean;
var
	i:LongInt;
begin
Result:=False;
for i:=0 to High(FUnits) do
	begin
	if FUnits[i].FIdentifity = Identifity then
		begin
		Result:=True;
		Break;
		end;
	end;
end;

function TSGXNovaBuildingsWaiting.GetLvlWithWaiting(const WaitingId:Int; const Identifity:Int = -1):Int;
var
	i:LongInt;
begin
if Identifity<>-1 then
	begin
	Result:=FUnits.FindUnit(Identifity);
	for i:=0 to WaitingId do
	if FWaiting[i]=Identifity then
		Result+=1;
	end
else
	begin
	if (WaitingId>=Low(FWaiting)) and (WaitingId<=High(FWaiting)) then
		begin
		Result:=FUnits.FindUnit(FWaiting[WaitingId]);
		for i:=0 to WaitingId do
			if FWaiting[i]=FWaiting[WaitingId] then
				Result+=1;
		end
	else
		Result:=0;
	end;
end;

function TSGXNovaBuildingsWaiting.GetNextBuildingLevel(const BuildingID:Int):Int;
begin
Result:=FUnits.FindUnit(BuildingID)+1;
end;

function TSGXNovaBuildingsWaiting.GetBuildTime(
	const Identifity:Int;
	const Quantity:Int;
	const Documentation:TSGXNovaUnitsDocumentation;
	const PositionInWaiting:Int = -1):Int;
var
	Time:real = 0;
	i:LongInt;
	iii,ii:LongInt;
begin
Time:=TSGXNovaWorld.GetResQuantity(
	Documentation.FDocumentation[Identifity].FBuildTime,
	Documentation.FDocumentation[Identifity].FBuildTimeProcent,
	Quantity);
for i:=0 to High(FUnits.FUnits) do
	begin
	if (Documentation.FDocumentation[FUnits.FUnits[i].FIdentifity].FType=XNovaBuilding) and
		(Documentation.FDocumentation[FUnits.FUnits[i].FIdentifity].FDecBuildTime<>0) and 
		(Documentation.FDocumentation[FUnits.FUnits[i].FIdentifity].FDecBuildTimeProcent<>0) then
		begin
		if PositionInWaiting = -1 then
			begin
			Time/=
				TSGXNovaWorld.GetResQuantity(
					Documentation.FDocumentation[FUnits.FUnits[i].FIdentifity].FDecBuildTime,
					Documentation.FDocumentation[FUnits.FUnits[i].FIdentifity].FDecBuildTimeProcent,
					FUnits.FUnits[i].FQuantity);
			end
		else
			begin
			ii:=0;
			for iii:=0 to PositionInWaiting-1 do
				if FWaiting[iii]=FUnits.FUnits[i].FIdentifity then
					begin
					ii:=1;
					break;
					end;
			if ii=0 then
				Time/=
					TSGXNovaWorld.GetResQuantity(
						Documentation.FDocumentation[FUnits.FUnits[i].FIdentifity].FDecBuildTime,
						Documentation.FDocumentation[FUnits.FUnits[i].FIdentifity].FDecBuildTimeProcent,
						FUnits.FUnits[i].FQuantity);
			end;
		end;
	end;
if PositionInWaiting<>-1 then
	begin
	for i:=PositionInWaiting-1 downto 0 do
		begin
		if (Documentation.FDocumentation[FWaiting[i]].FType=XNovaBuilding) and
			(Documentation.FDocumentation[FWaiting[i]].FDecBuildTime<>0) and 
			(Documentation.FDocumentation[FWaiting[i]].FDecBuildTimeProcent<>0)then
			begin
			ii:=0;
			for iii:=PositionInWaiting-1 downto i+1 do
				if FWaiting[iii]=FWaiting[i] then
					begin
					ii:=1;
					Break;
					end;
			if ii=0 then
				begin
				Time/=
					TSGXNovaWorld.GetResQuantity(
						Documentation.FDocumentation[FWaiting[i]].FDecBuildTime,
						Documentation.FDocumentation[FWaiting[i]].FDecBuildTimeProcent,
						GetLvlWithWaiting(i,FWaiting[i]));
				end;
			end;
		end;
	end;
Result:=Trunc(Time);
end;

procedure TSGXNovaBuildingsWaiting.NewBuilding(const Identifity:Int;const Time:Int);inline;
begin
if Length(FWaiting)=0 then
	begin
	FSeconds:=Time;
	SetLength(FWaiting,1);
	FWaiting[0]:=Identifity;
	end
else
	begin
	SetLength(FWaiting,Length(FWaiting)+1);
	FWaiting[High(FWaiting)]:=Identifity;
	end;
end;

function TSGXNovaPlanet.GetUserPlanet(const User:string):TSGXNovaUserPlanet;
var
	i:LongInt;
begin
Result:=nil;
for i:=0 to High(FUserPlanets) do
	if FUserPlanets[i].FUser=User then
		begin
		Result:=FUserPlanets[i];
		Break;
		end;
end;

procedure TSGXNovaWorld.UpDate(const Seconds:Int;const Documentation:TSGXNovaUnitsDocumentation);overload;
var
	Waiting:TSGXNovaWaitingClasses = nil;
	i:LongInt;
begin
FPlanets.GetWaiting(Seconds,Waiting,Documentation);
{$}
for i:=0 to High(Waiting) do
	begin
	Waiting[i].Go(Documentation);
	Waiting[i].Destroy;
	end;
end;

procedure TSGXNovaBuildingWaitingClass.Go(const Documentation:TSGXNovaUnitsDocumentation);
begin
FWaiting.UpDate(Documentation);
end;

procedure TSGXNovaBuildingsWaiting.UpDate(const Documentation:TSGXNovaUnitsDocumentation);
var
	i:LongInt;
begin
FUnits.IncUnit(FWaiting[0]);
for i:=1 to High(FWaiting) do
	FWaiting[i-1]:=FWaiting[i];
SetLength(FWaiting,Length(FWaiting)-1);
end;

procedure TSGXNovaBuildingsWaiting.GetWaiting(const Seconds:Int;var Waiting:TSGXNovaWaitingClasses;const Documentation:TSGXNovaUnitsDocumentation);
var
	Sec:Int;
	i:LongInt = 0;
begin
Sec:=Seconds;
while (Sec>0) and (i<Length(FWaiting)) do
	begin
	if Sec>=FSeconds then
		begin
		Sec-=FSeconds;
		SetLength(Waiting,Length(Waiting)+1);
		Waiting[High(Waiting)]:=TSGXNovaBuildingWaitingClass.Create(Self,Seconds-Sec);
		i+=1;
		if (i<Length(FWaiting)) then
			FSeconds:=GetBuildTime(FWaiting[i],GetLvlWithWaiting(i,FWaiting[i]),Documentation,i);
		end
	else
		begin
		FSeconds-=Sec;
		Sec:=0;
		end;
	end;
end;

procedure TSGXNovaObject.GetWaiting(const Seconds:Int;var Waiting:TSGXNovaWaitingClasses;const Documentation:TSGXNovaUnitsDocumentation);
begin
end;

procedure TSGXNovaPlanets.GetWaiting(const Seconds:Int;var Waiting:TSGXNovaWaitingClasses;const Documentation:TSGXNovaUnitsDocumentation);
var
	i,ii:LongInt;
begin
for i:=0 to High(FPlanets) do
	for ii:=0 to High(FPlanets[i].FUserPlanets) do
		FPlanets[i].FUserPlanets[ii].FBildingsWaiting.GetWaiting(Seconds,Waiting,Documentation);
end;

constructor TSGXNovaBuildingWaitingClass.Create(const Waiting:TSGXNovaBuildingsWaiting;const Time:Int);
begin
inherited Create;
FTime:=Time;
FWaiting:=Waiting;
end;

destructor TSGXNovaBuildingWaitingClass.Destroy;
begin
inherited;
end;

procedure TSGXNovaUnits.IncUnit(const ID:Int;const Quantity:Int = 1);
var
	i:LongInt;
begin
for i:=0 to High(FUnits) do
	if FUnits[i].FIdentifity=ID then
		begin
		FUnits[i].FQuantity+=Quantity;
		Exit;
		end;
SetLength(FUnits,Length(FUnits)+1);
FUnits[High(FUnits)]:=TSGXNovaUnit.Create;
FUnits[High(FUnits)].FQuantity:=Quantity;
FUnits[High(FUnits)].FIdentifity:=ID;
end;

procedure TSGXNovaUserPlanet.UpDate(const Documentation:TSGXNovaUnitsDocumentation);
begin
FBildingsWaiting.UpDate(Documentation);
end;

procedure TSGXNovaPlanet.UpDate(const Documentation:TSGXNovaUnitsDocumentation);
var
	i:LongInt;
begin
for i:=0 to High(FUserPlanets) do
	FUserPlanets[i].UpDate(Documentation);
end;

procedure TSGXNovaPlanets.UpDate(const Documentation:TSGXNovaUnitsDocumentation);
var
	i:LongInt;
begin
for i:=0 to High(FPlanets) do
	FPlanets[i].UpDate(Documentation);
end;

class function TSGXNovaWorld.GetResQuantity(
	Res1Lvl:Extended;
	const Procent:Int;
	const Lvl:Int):Int;
var
	i:LongWord=0;
begin
for i:=2 to Lvl do
	Res1Lvl+=Res1Lvl*Procent/100;
Result:=Trunc(Res1Lvl);
end;

function TSGXNovaCoord.ToPChar:PCHar;
begin
Result:='[';
Result:=SGPCharTotal(Result,SGStringToPChar(SGStr(FGalaxy)));
Result:=SGPCharTotal(Result,':');
Result:=SGPCharTotal(Result,SGStringToPChar(SGStr(FSolarSystem)));
Result:=SGPCharTotal(Result,':');
Result:=SGPCharTotal(Result,SGStringToPChar(SGStr(FPosition)));
Result:=SGPCharTotal(Result,']');
end;

function TSGXNovaPlanet.BusyPoligones(const Documentation:TSGXNovaUnitsDocumentation):Int;
var
	i,ii:LongInt;
begin
Result:=0;
for i:=0 to High(FUserPlanets) do
	begin
	for ii:=0 to High(FUserPlanets[i].FUnits.FUnits) do
		begin
		if Documentation.FDocumentation[FUserPlanets[i].FUnits.FUnits[ii].FIdentifity].FType=XNovaBuilding then
			Result+=FUserPlanets[i].FUnits.FUnits[ii].FQuantity;
		end;
	end;
end;

procedure TSGXNovaUnitsDocumentation.LoadImages;
var
	i:LongInt;
{$IFDEF UNIX}
var
	ii:LongInt;
	{$ENDIF}
begin
{$IFDEF UNIX}
	for i:=0 to High(FDocumentation) do
		for ii:=1 to Length(FDocumentation[i].FCapture) do
			if FDocumentation[i].FCapture[ii]=WinSlash then
				FDocumentation[i].FCapture[ii]:=UnixSlash;
	{$ENDIF}
for i:=0 to High(FDocumentation) do
	begin
	if FDocumentation[i].FCapture<>'' then
		begin
		FDocumentation[i].FPicture:=TSGGLImage.Create(FDocumentation[i].FCapture);
		FDocumentation[i].FPicture.Loading;
		end;
	end;
end;

procedure TSGXNovaUnits.SetQuantityUnits(const ID,Quantity:Int);
var
	i:LongWord;
begin
for i:=0 to High(FUnits) do
	if FUnits[i].FIdentifity=ID then
		begin
		FUnits[i].FQuantity:=Quantity;
		Break;
		end;
end;

function TSGXNovaUnits.FindUnit(const ID:Int):Int;
var
	i:LongInt;
begin
Result:=0;
for i:=0 to High(FUnits) do
	begin
	if FUnits[i].FIdentifity=ID then
		begin
		Result:=FUnits[i].FQuantity;
		Break;
		end;
	end;
end;

function TSGXNovaWorld.GetPlanet(const User:String;const Number:LongInt):TSGXNovaPlanet;
var
	i:LongInt = -1;
	ii:LongInt = 0;
begin
Result:=nil;
for i:=0 to High(FPlanets.FPlanets) do
	if FPlanets.FPlanets[i].UserExists(User) then
		begin
		ii+=1;
		if ii=Number then
			begin
			Result:=FPlanets.FPlanets[i];
			Break;
			end;
		end;
end;

function TSGXNovaPlanet.UserExists(const User:String):Boolean;
var
	i:LongInt;
begin
Result:=False;
for i:=0 to High(FUserPlanets) do
	if FUserPlanets[i].FUser=User then
		begin
		Result:=True;
		Break;
		end;
end;

procedure TSGXNovaUnitsDocumentation.Load(const FileName:String);
var
	Fail:TextFile;
begin
if FileExists(FileName) then
	begin
	Assign(Fail,FileName);
	Reset(Fail);
	while not SeekEof(Fail) do
		begin
		SetLength(FDocumentation,Length(FDocumentation)+1);
		FDocumentation[High(FDocumentation)]:=TSGXNovaUnitDocumentation.Create;
		FDocumentation[High(FDocumentation)].Load(@Fail);
		end;
	Close(Fail);
	end;
end;

procedure TSGXNovaUnitDocumentation.Load(const FileName:String);
var
	Fail:TextFile;
begin
if FileExists(FileName) then
	begin
	Assign(Fail,FileName);
	Reset(Fail);
	Load(@Fail);
	Close(Fail);
	end;
end;

procedure TSGXNovaUnitDocumentation.Load(const TextFile:PText);
var
	Identifity:string;
	I:LongWord;
begin
Read(TextFile^,FType);
FName:=SGReadStringInQuotesFromTextFile(TextFile);
if not SeekEoln(TextFile^) then
	FCapture:=SGReadStringInQuotesFromTextFile(TextFile);
while not SeekEoln(TextFile^) do
	begin
	Identifity:=SGUpCaseString(SGReadWordFromTextFile(TextFile));
	if Identifity='MINING' then
		begin
		Read(TextFile^,I);
		SetLength(FMining,i);
		for i:=0 to High(FMining) do
			begin
			Read(TextFile^,FMining[i].FIdentifity);
			Read(TextFile^,FMining[i].FMining);
			Read(TextFile^,FMining[i].FProcent);
			end;
		end;
	if Identifity='PRICE' then
		begin
		Read(TextFile^,I);
		SetLength(FPrice,I);
		for i:=0 to High(FPrice) do
			begin
			Read(TextFile^,FPrice[i].FLvl);
			Read(TextFile^,FPrice[i].FIdentifity);
			Read(TextFile^,FPrice[i].FValue);
			Read(TextFile^,FPrice[i].FProcent);
			end;
		end;
	if Identifity='BUILDTIME' then
		begin
		Read(TextFile^,FBuildTime,FBuildTimeProcent);
		end;
	if Identifity='DECBUILDTIME' then
		begin
		Read(TextFile^,FDecBuildTime,FDecBuildTimeProcent);
		end;
	if Identifity='STARTQUANTITY' then
		begin
		Read(TextFile^,FStartQuantity);
		end;
	if Identifity='UNMINING' then 
		begin
		FUnMiningResourse:=True;
		end;
	end;
ReadLn(TextFile^);
end;

constructor TSGXNovaUnitDocumentation.Create;
begin
inherited;
FType:=0;
FName:='';
FCapture:='';
FPicture:=nil;
FPrice:=nil;
FMining:=nil;
FBuildTime:=0;
FBuildTimeProcent:=0;
FUnMiningResourse:=False;
FDecBuildTime:=0;
FDecBuildTimeProcent:=0;
FStartQuantity:=0;
end;

constructor TSGXNovaBuildingsWaiting.Create;
begin
inherited;
FSeconds:=0;
SetLength(FWaiting,0);
end;

destructor TSGXNovaBuildingsWaiting.Destroy;
begin
SetLength(FWaiting,0);
inherited;
end;

procedure TSGXNovaBuildingsWaiting.Load(const Stream:TStream);
var
	Quantity:Int;
begin
Stream.ReadBuffer(FSeconds,SizeOf(FSeconds));
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
SetLength(FWaiting,Quantity);
Stream.ReadBuffer(FWaiting[0],SizeOf(FWaiting[0])*Quantity);
end;

procedure TSGXNovaBuildingsWaiting.Save(const Stream:TStream);
var
	Quantity:Int;
begin
Quantity:=Length(FWaiting);
Stream.WriteBuffer(FSeconds,SizeOf(FSeconds));
Stream.WriteBuffer(Quantity,SizeOf(Quantity));
Stream.WriteBuffer(FWaiting[0],SizeOf(FWaiting[0])*Quantity);
end;

constructor TSGXNovaUserPlanet.Create;
begin
inherited;
FUser:='';
FMainPlanet:=False;
FUnits:=TSGXNovaUnits.Create;
FBildingsWaiting:=TSGXNovaBuildingsWaiting.Create;
FBildingsWaiting.FUnits:=FUnits;
end;

destructor TSGXNovaUserPlanet.Destroy;
begin
FUnits.Destroy;
FBildingsWaiting.Destroy;
inherited;
end;

procedure TSGXNovaUserPlanet.Load(const Stream:TStream);
begin
FUser:=SGReadStringFromStream(Stream);
Stream.ReadBuffer(FMainPlanet,SizeOf(FMainPlanet));
FUnits.Load(Stream);
FBildingsWaiting.Load(Stream);
end;

procedure TSGXNovaUserPlanet.Save(const Stream:TStream);
begin
SGWriteStringToStream(FUser,Stream);
Stream.WriteBuffer(FMainPlanet,SizeOf(FMainPlanet));
FUnits.Save(Stream);
FBildingsWaiting.Save(Stream);
end;

constructor TSGXNovaPlanets.Create;
begin
inherited;
FPlanets:=nil;
end;

destructor TSGXNovaPlanets.Destroy;
var
	i:LongWord;
begin
for i:=0 to High(FPlanets) do
	begin
	FPlanets[i].Destroy;
	end;
SetLength(FPlanets,0);
inherited;
end;

procedure TSGXNovaPlanets.Load(const Stream:TStream);
var
	Quantity:Int;
	i:LongWord;
begin
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
SetLength(FPlanets,Quantity);
for i:=0 to Quantity-1 do
	begin
	FPlanets[i]:=TSGXNovaPlanet.Create;
	FPlanets[i].Load(Stream);
	end;
end;

procedure TSGXNovaPlanets.Save(const Stream:TStream);
var
	Quantity:Int;
	i:LongWord;
begin
Quantity:=Length(FPlanets);
Stream.WriteBuffer(Quantity,SizeOf(Quantity));
for i:=0 to Quantity-1 do
	begin
	FPlanets[i].Save(Stream);
	end;
end;

function TSGXNovaWorld.VerificationPassword(const User,Password:String):Boolean;
var
	i:LongWord;
begin
Result:=False;
for i:=0 to High(FUsers.FUsers) do
	begin
	if (FUsers.FUsers[i][0]=User) and (FUsers.FUsers[i][1]=Password) then
		begin
		Result:=True;
		Break;
		end;
	end;
end;

constructor TSGXNovaPlanet.Create;
begin
inherited;
FCoord:=TSGXNovaCoord.Create;
FName:='';
FDiametr:=0;
FPolygones:=0;
FUserPlanets:=nil;
FNumberPicture:=0;
end;

destructor TSGXNovaPlanet.Destroy;
var
	i:LongWord;
begin
FCoord.Destroy;
for i:=0 to High(FUserPlanets) do
	FUserPlanets[i].Destroy;
SetLength(FUserPlanets,0);
inherited;
end;

procedure TSGXNovaPlanet.Load(const Stream:TStream);
var
	Quantity:Int;
	I:LongWord;
begin
FCoord.Load(Stream);
FName:=SGReadStringFromStream(Stream);
Stream.ReadBuffer(FDiametr,SizeOf(FDiametr));
Stream.ReadBuffer(FPolygones,SizeOf(FPolygones));
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
Stream.ReadBuffer(FNumberPicture,SizeOf(FNumberPicture));
SetLength(FUserPlanets,Quantity);
For i:=0 to High(FUserPlanets) do
	begin
	FUserPlanets[i]:=TSGXNovaUserPlanet.Create;
	FUserPlanets[i].Load(Stream);
	end;
end;

procedure TSGXNovaPlanet.Save(const Stream:TStream);
var
	Quantity:Int;
	I:LongWord;
begin
FCoord.Save(Stream);
SGWriteStringToStream(FName,Stream);
Quantity:=Length(FUserPlanets);
Stream.WriteBuffer(FDiametr,SizeOf(FDiametr));
Stream.WriteBuffer(FPolygones,SizeOf(FPolygones));
Stream.WriteBuffer(Quantity,SizeOf(Quantity));
Stream.WriteBuffer(FNumberPicture,SizeOf(FNumberPicture));
for i:=0 to High(FUserPlanets) do
	begin
	FUserPlanets[i].Save(Stream);
	end;
end;

class function TSGXNovaWorld.SGXNovaCoordsEqual(const a,b:TSGXNovaCoord):Boolean;inline;
begin
Result:=False;
if (a<>nil) and (b<>nil) and (a.FGalaxy=b.FGalaxy) and (a.FSolarSystem=b.FSolarSystem) and (a.FPosition = b.FPosition) then
	begin
	Result:= True;
	end;
end;

procedure TSGXNovaCoord.CreateRandom;
begin
FGalaxy:=Random(9999)+1;
FSolarSystem:=Random(9999)+1;
FPosition:=Random(9999)+1;
FThat:=1;
end;

class function TSGXNovaObject.GetPolygonesFromDiametr(const Diamert:Int):Int;
begin
Result:=Round(4*sqr(Diamert/2)*Pi/5000);
end;

procedure TSGXNovaPlanet.CreateRandom(const User:String; const Documentation:TSGXNovaUnitsDocumentation = nil);
const 
	Proc = 1000000;
var
	i:LongInt;
begin
FCoord.CreateRandom;
FName:='New Planet';
FDiametr:=Random(40000)+10000;
FPolygones:=Round(GetPolygonesFromDiametr(FDiametr)*((random(Trunc(Proc*0.4))+Proc*0.5)/Proc));
FNumberPicture:=random(59)+1;
SetLength(FUserPlanets,1);
FUserPlanets[0]:=TSGXNovaUserPlanet.Create;
for i:=0 to High(Documentation.FDocumentation) do
	if Documentation.FDocumentation[i].FStartQuantity<>0 then
		FUserPlanets[0].FUnits.IncUnit(i,Documentation.FDocumentation[i].FStartQuantity);
FUserPlanets[0].FUser:=User;
FUserPlanets[0].FMainPlanet:=True;
end;

procedure TSGXNovaWorld.CreateNewUser(const NewUser,NewPassword:String; const Documentation:TSGXNovaUnitsDocumentation = nil);
label 
	ReProverka;
var
	i:LongWord;
begin
SetLength(FUsers.FUsers,Length(FUsers.FUsers)+1);
FUsers.FUsers[High(FUsers.FUsers)][0]:=NewUser;
FUsers.FUsers[High(FUsers.FUsers)][1]:=NewPassword;
SetLength(FPlanets.FPlanets,Length(FPlanets.FPlanets)+1);
FPlanets.FPlanets[High(FPlanets.FPlanets)]:=TSGXNovaPlanet.Create;
FPlanets.FPlanets[High(FPlanets.FPlanets)].CreateRandom(NewUser,Documentation);
ReProverka:
i:=0;
while i<>High(FPlanets.FPlanets) do
	begin
	if SGXNovaCoordsEqual(
		FPlanets.FPlanets[High(FPlanets.FPlanets)].FCoord,
		FPlanets.FPlanets[i].FCoord) then
			begin
			FPlanets.FPlanets[High(FPlanets.FPlanets)].FCoord.CreateRandom;
			goto ReProverka;
			end;
	i+=1;
	end;
end;

constructor TSGXNovaWorld.Create;
begin
inherited;
FUsers:=TSGXNovaUsers.Create;
FFleets:=TSGXNovaFeets.Create;
FPlanets:=TSGXNovaPlanets.Create;
end;

destructor TSGXNovaWorld.Destroy;
begin
FUsers.Destroy;
FFleets.Destroy;
FPlanets.Destroy;
inherited;
end;

procedure TSGXNovaWorld.Load(const Stream:TStream);
begin
Stream.Position:=0;
Stream.ReadBuffer(FDateTime,SizeOf(FDateTime));
FUsers.Load(Stream);
FFleets.Load(Stream);
FPlanets.Load(Stream);
end;

procedure TSGXNovaWorld.Save(const Stream:TStream);overload;
begin
Stream.WriteBuffer(FDateTime,SizeOf(FDateTime));
FUsers.Save(Stream);
FFleets.Save(Stream);
FPlanets.Save(Stream);
end;

constructor TSGXNovaUnits.Create;
begin
inherited;
SetLEngth(FUnits,0);
end;

destructor TSGXNovaUnits.Destroy;
var
	i:LongInt;
begin
for i:=0 to High(FUnits) do
	FUnits[i].Destroy;
SetLEngth(FUnits,0);
inherited;
end;

procedure TSGXNovaUnits.Load(const Stream:TStream);
var
	Quantity:Int;
	I:LongInt;
begin
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
SetLength(FUnits,Quantity);
for i:=0 to High(FUnits) do
	begin
	FUnits[i]:=TSGXNovaUnit.Create;
	FUnits[i].Load(Stream);
	end;
end;

procedure TSGXNovaUnits.Save(const Stream:TStream);
var
	I:LongInt;
	Quantity:Int;
begin
Quantity:=Length(FUnits);
Stream.WriteBuffer(Quantity,SizeOf(Quantity));
for i:=0 to High(FUnits) do
	FUnits[i].Save(Stream);
end;

constructor TSGXNovaUnit.Create;
begin
inherited;
FQuantity:=0;
FIdentifity:=0;
end;

destructor TSGXNovaUnit.Destroy;
begin
inherited;
end;

procedure TSGXNovaUnit.Load(const Stream:TStream);
begin
Stream.ReadBuffer(FIdentifity,SizeOf(FIdentifity)*2);
end;

procedure TSGXNovaUnit.Save(const Stream:TStream);
begin
Stream.WriteBuffer(FIdentifity,SizeOf(FIdentifity)*2);
end;

procedure TSGXNovaObject.UpDate(const Documentation:TSGXNovaUnitsDocumentation);
begin
end;

constructor TSGXNovaObject.Create;
begin
inherited;
end;

constructor TSGXNovaCoord.Create;
begin
inherited;
FGalaxy:=0;
FSolarSystem:=0;
FPosition:=0;
FThat:=0;
end;

destructor TSGXNovaCoord.Destroy;
begin
inherited;
end;

procedure TSGXNovaCoord.Load(const Stream:TStream);
begin
Stream.ReadBuffer(FGalaxy,SizeOf(FGalaxy)*4);
end;

procedure TSGXNovaCoord.Save(const Stream:TStream);
begin
Stream.WriteBuffer(FGalaxy,SizeOf(FGalaxy)*4);
end;

constructor TSGXNovaFeet.Create;
begin
inherited;
FResourses:=TSGXNovaUnits.Create;
FUnits:=TSGXNovaUnits.Create;
FCoord1:=TSGXNovaCoord.Create;
FCoord2:=TSGXNovaCoord.Create;
FMission:=0;
FUserName:='';
end;

destructor TSGXNovaFeet.Destroy;
begin
FResourses.Destroy;
FUnits.Destroy;
FCoord1.Destroy;
FCoord2.Destroy;
inherited;
end;

procedure TSGXNovaFeet.Load(const Stream:TStream);
begin
FUserName:=SGReadStringFromStream(Stream);
Stream.ReadBuffer(FDateTime,SizeOf(FDateTime));
FCoord1.Load(Stream);
FCoord2.Load(Stream);
Stream.ReadBuffer(FMission,SizeOf(FMission));
FUnits.Load(Stream);
FResourses.Load(Stream);
end;

procedure TSGXNovaFeet.Save(const Stream:TStream);
begin
SGWriteStringToStream(FUserName,Stream);
Stream.WriteBuffer(FDateTime,SizeOf(FDateTime));
FCoord1.Save(Stream);
FCoord2.Save(Stream);
Stream.WriteBuffer(FMission,SizeOf(FMission));
FUnits.Save(Stream);
FResourses.Save(Stream);
end;

constructor TSGXNovaFeets.Create;
begin
inherited;
SetLength(FFleets,0);
end;

destructor TSGXNovaFeets.Destroy;
var
	I:LongInt;
begin
SetLength(FFleets,0);
for i:=0 to High(FFleets) do
	FFleets[i].Destroy;
inherited;
end;

procedure TSGXNovaFeets.Load(const Stream:TStream);
var
	Quantity:Int;
	I:LongInt;
begin
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
SetLength(FFleets,Quantity);
for i:=0 to High(FFleets) do
	begin
	FFleets[i]:=TSGXNovaFeet.Create;
	FFleets[i].Load(Stream);
	end;
end;

procedure TSGXNovaFeets.Save(const Stream:TStream);
var
	Quantity:Int;
	I:LongInt;
begin
Quantity:=Length(FFleets);
Stream.WriteBuffer(Quantity,SizeOf(Quantity));
for i:=0 to High(FFleets) do
	FFleets[i].Save(Stream);
end;

constructor TSGXNovaUsers.Create;
begin
inherited;
SetLength(FUsers,0);
end;

destructor TSGXNovaUsers.Destroy;
begin
SetLength(FUsers,0);
inherited;
end;

procedure TSGXNovaUsers.Load(const Stream:TStream);
var
	Quantity:Int;
	i:LongInt;
begin
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
SetLength(FUsers,Quantity);
for i:=0 to High(FUsers) do
	begin
	FUsers[i][0]:=SGReadStringFromStream(Stream);
	FUsers[i][1]:=SGReadStringFromStream(Stream);
	end;
end;

procedure TSGXNovaUsers.Save(const Stream:TStream);
var
	Quantity:Int;
	i:LongInt;
begin
Quantity:=Length(FUsers);
Stream.WriteBuffer(Quantity,SizeOf(Quantity));
for i:=0 to High(FUsers) do
	begin
	SGWriteStringToStream(FUsers[i][0],Stream);
	SGWriteStringToStream(FUsers[i][1],Stream);
	end;
end;


end.

{constructor .Create;
begin
inherited;
end;

destructor .Destroy;
begin
inherited;
end;

procedure .Load(const Stream:TStream);
begin

end;

procedure .Save(const Stream:TStream);
begin

end;}
