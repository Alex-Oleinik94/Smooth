{$INCLUDE SaGe.inc}

unit SaGeFPCToC;

interface

uses
	 Classes
	
	,SaGeStringUtils
	,SaGeBase
	,SaGeBased
	,SaGeConsoleToolsBase
	;

type
	SGTranslater=class;
	
	SGTInfoChunk=class 
			public
		constructor Create(const Dir,Id:String);
			public
		FDirictive,FIdentity:String; 
		end;
	
	SGTInfo=class
			public
		constructor Create;
		destructor Destroy;override;
			public
		FInfo:packed array of SGTInfoChunk;
			public
		function Defined(const Id:String):Boolean;
		function Mode:String;
		function AsmMode:String;
		function H:Boolean;
		procedure Add(const NewInfo:SGTInfoChunk);
		procedure DeleteIf;
		end;
	
	SGTRead=class
			public
		constructor Create;overload;
		destructor Destroy;override;
		class function Create(const Way:String):SGTRead;overload;
			public
		FWay:string;
		FStream:TFileStream;
		FMember:packed array of 
			packed record 
			FPosition:Int64;
			FLine,FColumn:LongWord;
			end;
		FLine,FColumn:LongWord;
			public
		function NextIdentifier:string;
		function ReadCircle:string;
		procedure MovePos(const I:Int64);
		function ReadChar:Char;
		procedure Member;
		procedure ReMember;
		function StringInfo:String;
		end;
	TSGTRead=SGTRead;
	
	SGTReadClass=class
			public
		constructor Create;overload;
		destructor Destroy;override;
		class function Create(const TRead:SGTRead):SGTReadClass;overload;
		procedure Add(const TRead:SGTRead);
		function NextIdentifier:String;
		procedure UnReadComments;
		function ReadChar:Char;
		procedure Member;
		procedure ReMember;
		function StringInfo:String;
			public
		FFiles:packed array of SGTRead;
		FInfo:SGTInfo;
		FWithComments:Boolean;
		FWithDirictives:Boolean;
		end;
	TSGTReadClass=SGTReadClass;
	
	SGTWriteClass=class
			public
		constructor Create(const Way:String);
		destructor Destroy;override;
		procedure Write(const s:String);
		procedure WriteLn(const s:string);
			public
		FStream:TFileStream;
		end;
	
	SGTUPlace=(SGTUUnsigned,SGTUHeader,SGTUCPP);
	SGTComponent=class
			public
		class function ClassName:string;virtual;
		constructor Create;virtual;
		destructor Destroy;override;
		procedure GoRead;virtual;
		procedure GoWrite(const FWriteClass:SGTWriteClass = nil);virtual;
		function IsZS(const Ar:array of const;const Sl:String):Boolean;
		procedure Add(const NewComponent:SGTComponent);
		function TransliatorClass:SGTranslater;
		function LastChunk:SGTComponent;inline;
			private
		function GetOutWay:string;virtual;
			public
		FChunks:packed array of SGTComponent;
		FPlace:SGTUPlace;
		FParent:SGTComponent;
		FName:String;
		FWay:String;
			public
		property Way:string read FWay write FWay;
		property OutWay:string read GetOutWay;
		end;
	TSGTComponent=SGTComponent;
	
	SGTModule=class(SGTComponent) 
		class function ClassName:string;override;
		procedure GoWrite(const FWriteClass:SGTWriteClass = nil);override;
		end;
	
	SGTReadClassComponent=class(SGTComponent)
			public
		class function ClassName:string;override;
		constructor Create;override;
		destructor Destroy;override;
		function NextIdentifierIsZS:Boolean;
		function NextIdentifierMRM:string;
		procedure SourceToLog(const Ar:packed array of const);
			public
		FReadClass:SGTReadClass;
		end;
	
	SGTComment=class(SGTReadClassComponent)
			public
		class function ClassName:string;override;
		constructor Create;override;
		destructor Destroy;override;
		procedure GoRead;override;
		procedure GoWrite(const FWriteClass:SGTWriteClass = nil);override;
			public
		FComment:String;
		end;
	TSGTComment = SGTComment;
	
	SGTExpression = class(SGTReadClassComponent)
			public
		class function ClassName:string;override;
		constructor Create;override;
		destructor Destroy;override;
		procedure GoRead;override;
		procedure GoWrite(const FWriteClass:SGTWriteClass = nil);override;
		end;
	TSGTExpression = SGTExpression;
	
	SGTVar=class(SGTReadClassComponent)
			public
		class function ClassName:string;override;
		constructor Create;override;
		destructor Destroy;override;
		procedure GoRead;override;
		procedure GoWrite(const FWriteClass:SGTWriteClass = nil);override;
			public
		FVariables:packed array of String;
		FType:String;
		FExpression:SGTExpression;
		end;
	TSGTVar = SGTVar;
	
	SGTConst=class(SGTReadClassComponent)
		public
		class function ClassName:string;override;
		constructor Create;override;
		destructor Destroy;override;
		procedure GoRead;override;
		procedure GoWrite(const FWriteClass:SGTWriteClass = nil);override;
			public
		FConst:String;
		FType:String;
		FExpression:SGTExpression;
		end;
	
	SGTProcedure = class(SGTReadClassComponent)
			public
		class function ClassName:string;override;
		constructor Create;override;
		destructor Destroy;override;
		procedure GoRead;override;
		procedure GoWrite(const FWriteClass:SGTWriteClass = nil);override;
			public
		FParametrs:packed array of
			packed record 
			FType,FTypeType:String;
			FExpression:SGTExpression;
			FNames:packed array of
				String;
			end;
		end;
	TSGTProcedure = SGTProcedure;
	
	SGTUnit=class(SGTReadClassComponent)
			public
		class function ClassName:string;override;
		constructor Create;override;
		destructor Destroy;override;
			public
		procedure GoRead;override;
		procedure GoWrite(const FWriteClass:SGTWriteClass = nil);override;
		end;
	TSGTUnit=SGTUnit;
	
	TSGTProgram=class(SGTReadClassComponent)
			public
		class function ClassName:string;override;
		constructor Create;override;
		destructor Destroy;override;
			public
		procedure GoRead;override;
		procedure GoWrite(const FWriteClass:SGTWriteClass = nil);override;
		end;
	SGTProgram=TSGTProgram;
	
	SGTBeginEnd=class(SGTReadClassComponent)
			public
		class function ClassName:string;override;
		constructor Create;override;
		destructor Destroy;override;
		procedure GoRead;override;
		procedure GoWrite(const FWriteClass:SGTWriteClass = nil);override;
		end;
	TSGTBeginEnd = SGTBeginEnd;
	
	SGTranslater=class(SGTComponent)
			public
		class function ClassName:string;override;
		constructor Create;override;overload;
		destructor Destroy;override;
		class function Create(const VWay:String):SGTranslater;overload;
			public
		FObject:string;
		FWays:packed array of String;
		FOutWay:string;
		FParams : TSGConcoleCallerParams;
			private
		function GetOutWay:string;override;
			public
		procedure GoRead;override;
		procedure GoTranslate;inline;
		procedure GoWrite(const FWriteClass:SGTWriteClass = nil);override;
		function FileType(const VWay:string):string;
		function GoFindAndReadUnit(const VWay:string):Boolean;
			public
		property Params : TSGConcoleCallerParams read FParams write FParams;
		end;
	TSGTranslater=SGTranslater;

implementation

uses
	 SaGeLog
	;
{==============}(*SGTExpression*){==============}

class function SGTExpression.ClassName:string;
begin
Result:='EXPRESSION';
end;

constructor SGTExpression.Create;
begin
inherited;
end;

destructor SGTExpression.Destroy;
begin
inherited;
end;

procedure SGTExpression.GoRead;
var
	NI:String = '';
function IsNumber(const n:string):Boolean;
var
	i:LongWord;
begin
Result:=true;
for i:=1 to Length(n) do
	if not (n[i] in ['0','1'..'9']) then
		begin
		Result:=False;
		Exit;
		end;
end;

function Hare:Boolean;
begin
FReadClass.Member;
Result:=NextIdentifierIsZS or (NextIdentifierMRM=';')or (NextIdentifierMRM=',')or (NextIdentifierMRM=']')or (NextIdentifierMRM=')');
FReadClass.ReMember;
end;

begin
SourceToLog(['SGTExpression.GoRead : Beginning']);
repeat
NI:=FReadClass.NextIdentifier;
Add(SGTComment.Create);
SourceToLog(['SGTExpression.GoRead : Adding "',NI,'"']);
LastChunk.FName:=NI;
until hare;
SourceToLog(['SGTExpression.GoRead : End']);
end;

procedure SGTExpression.GoWrite(const FWriteClass:SGTWriteClass = nil);
var
	I:LongWord;
begin
if FChunks<>nil then
	for i:=0 to High(FChunks) do
		FWriteClass.Write(FChunks[i].FName);
end;

{==========}(*SGTConst*){=================}
class function SGTConst.ClassName:string;
begin
Result:='CONST';
end;

constructor SGTConst.Create;
begin
inherited;
FConst:='';
FType:='';
FExpression:=nil;
end;

destructor SGTConst.Destroy;
begin
if FExpression<>nil then
	FExpression.Destroy;
inherited;
end;

procedure SGTConst.GoRead;
var
	NI:String = '';
begin
FConst:=FReadClass.NextIdentifier;
NI:=FReadClass.NextIdentifier;

if NI=':' then
	begin
	FType:=FReadClass.NextIdentifier;
	FReadClass.NextIdentifier;
	end;

FExpression:=SGTExpression.Create;
FExpression.FParent:=Self;
FExpression.FReadClass:=FReadClass;
FExpression.GoRead;

FReadClass.NextIdentifier;
end;

procedure SGTConst.GoWrite(const FWriteClass:SGTWriteClass = nil);
begin
if FType = '' then
	begin
	FWriteClass.Write('#define '+FConst+' ');
	FExpression.GoWrite(FWriteClass);
	FWriteClass.WriteLn('');
	end
else
	begin
	FWriteClass.Write('static '+FType+' '+FConst+' = ');
	FExpression.GoWrite(FWriteClass);
	FWriteClass.WriteLn(' ;');
	end;
end;

{============}(*SGTWriteClass*){============}

constructor SGTWriteClass.Create(const Way:String);
begin
inherited Create;
FStream:=TFileStream.Create(Way,fmCreate);
end;

destructor SGTWriteClass.Destroy;
begin
if FStream<>nil then
	FStream.Destroy;
inherited;
end;

procedure SGTWriteClass.Write(const s:String);
var
	P:PChar;
begin
P:=SGStringToPChar(s);
FStream.WriteBuffer(P[0],Length(s));
end;

procedure SGTWriteClass.WriteLn(const s:string);
begin
Write(s+#13+#10);
end;

{=============}(*SGTModule*){=============}
class function SGTModule.ClassName:string;
begin
Result:='MODULE';
end;

procedure SGTModule.GoWrite(const FWriteClass:SGTWriteClass = nil);
begin
FWriteClass.WriteLn('#include "'+FName+'.h"');
end;

{============}(*SGTProcedure*){============}
class function SGTProcedure.ClassName:string;
begin
Result:='PROCEDURE';
end;

constructor SGTProcedure.Create;
begin
inherited;
FParametrs:=nil;
end;

destructor SGTProcedure.Destroy;
var
	i:LongWord;
begin
if FParametrs<>nil then
	begin
	for i:=0 to High(FParametrs) do
		begin
		if FParametrs[i].FExpression<>nil then
			FParametrs[i].FExpression.Destroy;
		if FParametrs[i].FNames<>nil then
			SetLength(FParametrs[i].FNames,0);
		FParametrs[i].FTypeType:='';
		FParametrs[i].FType:='';
		end;
	SetLength(FParametrs,0);
	end;
inherited;
end;
{$Note SGTProcedure}
procedure SGTProcedure.GoRead;
var
	NI:String = '';
begin
SourceToLog(['SGTProcedure.GoRead : Begin read header procedure']);
FName:=FReadClass.NextIdentifier;
SourceToLog(['SGTProcedure.GoRead : Name procedure is "',FName,'"']);
NI:=FReadClass.NextIdentifier;
if NI='(' then
	begin
	NI:=FReadClass.NextIdentifier;
	while NI<>')' do
		begin
		SourceToLog(['SGTProcedure.GoRead : Begin to read parametr procedure "',FName,'"']);
		if FParametrs=nil then
			SetLength(FParametrs,1)
		else
			SetLength(FParametrs,Length(FParametrs)+1);
		FParametrs[High(FParametrs)].FTypeType:='';
		FParametrs[High(FParametrs)].FType:='';
		FParametrs[High(FParametrs)].FNames:=nil;
		FParametrs[High(FParametrs)].FExpression:=nil;
		if (NI='CONST') or (NI='VAR') or (NI='OUT') then
			begin
			SourceToLog(['SGTProcedure.GoRead : type of type "',Length(FParametrs),'" is "',NI,'"']);
			FParametrs[High(FParametrs)].FTypeType:=NI;
			NI:=FReadClass.NextIdentifier;
			end;
		while NI<>':' do
			begin
			SourceToLog(['SGTProcedure.GoRead : Begin to read variable parametr procedure "',FName,'"']);
			if FParametrs[High(FParametrs)].FNames=nil then
				SetLength(FParametrs[High(FParametrs)].FNames,1)
			else
				SetLength(FParametrs[High(FParametrs)].FNames,Length(FParametrs[High(FParametrs)].FNames)+1);
			FParametrs[High(FParametrs)].FNames[High(FParametrs[High(FParametrs)].FNames)]:=NI;
			NI:=FReadClass.NextIdentifier;
			if NI=',' then
				NI:=FReadClass.NextIdentifier;
			end;
		FParametrs[High(FParametrs)].FType:=FReadClass.NextIdentifier;
		NI:=FReadClass.NextIdentifier; { ; = }
		if NI = '=' then
			begin
			FParametrs[High(FParametrs)].FExpression:=SGTExpression.Create;
			FParametrs[High(FParametrs)].FExpression.FParent:=Self;
			FParametrs[High(FParametrs)].FExpression.FReadClass:=FReadClass;
			FParametrs[High(FParametrs)].FExpression.GoRead;
			
			NI:=FReadClass.NextIdentifier;
			end;
		if NI<>')' then
			NI:=FReadClass.NextIdentifier;
		end;
	FReadClass.NextIdentifier;
	end;
SourceToLog(['SGTProcedure.GoRead : End read header procedure']);
if FPlace<>SGTUHeader then
	begin
	SourceToLog(['SGTProcedure.GoRead : Begin to read chuncks procedure "',FName,'"']);
	repeat
	NI:=FReadClass.NextIdentifier;
	if NI='PROCEDURE' then
		begin
		Add(SGTProcedure.Create);
		LastChunk.GoRead;
		end
	else if (NI='VAR') then
		begin
		repeat
		Add(SGTVar.Create);
		LastChunk.GoRead;
		until NextIdentifierIsZS;
		end
	else if (NI='CONST') then
		begin
		repeat
		Add(SGTConst.Create);
		LastChunk.GoRead;
		until NextIdentifierIsZS; 
		end
	else if NI='{' then
		begin
		Add(SGTComment.Create);
		FChunks[High(FChunks)].GoRead;
		end
	else if NI='BEGIN' then
		begin
		Add(SGTBeginEnd.Create);
		LastChunk.GoRead;
		NI := 'END';
		end;
	until NI='END';
	end;
end;

procedure SGTProcedure.GoWrite(const FWriteClass:SGTWriteClass = nil);
var
	i,ii,iii:LongWord;
begin
iii:=0;
FWriteClass.Write('void ');
FWriteClass.Write(FName);
FWriteClass.Write(' ( ' );
if FParametrs<>nil then
	begin
	for i:=0 to High(FParametrs) do
		begin
		if FParametrs[i].FNames<>nil then
			begin
			for ii:=0 to High(FParametrs[i].FNames) do
				begin
				if iii<>0 then
					begin
					FWriteClass.Write(' , ');
					end;
				if FParametrs[i].FTypeType = 'CONST' then
					FWriteClass.Write(' const ');
				FWriteClass.Write(FParametrs[i].FType+' '+FParametrs[i].FNames[ii]);
				iii:=1;
				end;
			end;
		end;
	end;
if FPlace=SGTUHeader then
	FWriteClass.WriteLn(' ) ;')
else
	begin
	FWriteClass.WriteLn(' ) {');
	if FChunks<>nil then
	for i:=0 to High(FChunks) do
		FChunks[i].GoWrite(FWriteClass);
	FWriteClass.WriteLn(' } ');
	end;
end;


{===========}(*SGTVar*){===========}
procedure SGTVar.GoWrite(const FWriteClass:SGTWriteClass = nil);
var
	i:LongWord;
begin
for i:=0 to High(FVariables) do
	FWriteClass.WriteLn(FType+' '+FVariables[i]+' ;');
end;

class function SGTVar.ClassName:string;
begin
Result:='VAR';
end;

constructor SGTVar.Create;
begin
inherited;
FType:='';
FExpression:=nil;
FVariables:=nil;
end;

destructor SGTVar.Destroy;
begin
if (FVariables<>nil) and (Length(FVariables)<>0) then
	begin
	SetLength(FVariables,0);
	end;
if FExpression<>nil then
	FExpression.Destroy;
inherited;
end;

procedure SGTVar.GoRead;
var
	NI:String;

procedure AddVariable(const Variable:string);
begin
if FVariables<>nil then
	SetLength(FVariables,Length(FVariables)+1)
else
	SetLength(FVariables,1);
FVariables[high(FVariables)]:=Variable;
end;

begin
repeat
NI:=FReadClass.NextIdentifier;
AddVariable(NI);
NI:=FReadClass.NextIdentifier;
until NI=':';

FType:=FReadClass.NextIdentifier;

if FReadClass.NextIdentifier='=' then
	begin
	FExpression:=SGTExpression.Create;
	FExpression.FParent:=Self;
	FExpression.FReadClass:=FReadClass;
	FExpression.GoRead;
	
	FReadClass.NextIdentifier;
	end;

SourceToLog(['SGTVariable.GoRead : Succsesful Of Type "',FType,'"']);
end;

{===========}(*SGTComment*){===========}

procedure SGTComment.GoWrite(const FWriteClass:SGTWriteClass = nil);
begin
FWriteClass.Write('/*'+FComment+'*/');
end;

class function SGTComment.ClassName:string;
begin
Result:='COMMENT';
end;

constructor SGTComment.Create;
begin
inherited;
FComment:='';
end;

destructor SGTComment.Destroy;
begin
inherited;
end;

procedure SGTComment.GoRead;
var
	i:LongWord;
	c:char;
begin
FComment:='';
i:=1;
repeat
c:=FReadClass.ReadChar;
case c of
'{':i+=1;
'}':i-=1;
end;
if i<>0 then
	FComment+=c;
//SourceToLog(['SGTComment.GoRead : I = "',i,'", FComment = "',FComment,'"']);
until i=0;
end;

{=============}(*SGTInfoChunk*){===========}

constructor SGTInfoChunk.Create(const Dir,Id:String);
begin
inherited Create;
FIdentity:=Id;
FDirictive:=Dir;
end;

{==================}(*SGTInfo*){================}

procedure SGTInfo.DeleteIf;
var
	i,ii:LongWord;
begin
i:=0;
if FInfo<>nil then
	for i:=High(FInfo) downto 0 do
		begin
		if FInfo[i].FDirictive='IF' then
			Break;
		end;
if (FInfo<>nil) and (Length(FInfo)>0) and (FInfo[i].FDirictive='IF') then
	begin
	FInfo[i].Destroy;
	for ii:=i to High(FInfo)-1 do
		FInfo[ii]:=FInfo[ii+1];
	SetLength(FInfo,Length(FInfo)-1);
	end;
end;

procedure SGTInfo.Add(const NewInfo:SGTInfoChunk);
begin
if FInfo=nil then
	SetLength(FInfo,1)
else
	SetLength(FInfo,Length(FInfo)+1);
FInfo[High(FInfo)]:=NewInfo;
end;

function SGTInfo.Defined(const Id:String):Boolean;
var
	i:LongWord;
begin
Result:=False;
if FInfo<>nil then
	for i:=0 to High(FInfo) do
		if FInfo[i].FDirictive = 'DEFINE' then
			if FInfo[i].FIdentity = Id then
				Result:=True
			else
		else
			if FInfo[i].FDirictive = 'UNDEF' then
				if FInfo[i].FIdentity = Id then
					Result:=False;
end;

function SGTInfo.Mode:String;
var
	i:LongWord;
begin
Result:='FPC';
if FInfo<>nil then
	for i:=0 to High(FInfo) do
		if FInfo[i].FDirictive = 'MODE' then
			Result:=FInfo[i].FIdentity;
end;

function SGTInfo.AsmMode:String;
var
	i:LongWord;
begin
Result:='INTEL';
if FInfo<>nil then
	for i:=0 to High(FInfo) do
		if FInfo[i].FDirictive = 'ASMMODE' then
			Result:=FInfo[i].FIdentity;
end;

function SGTInfo.H:Boolean;
var
	i:LongWord;
begin
Result:=False;
if FInfo<>nil then
	for i:=0 to High(FInfo) do
		if FInfo[i].FDirictive = 'H' then
			if (FInfo[i].FIdentity='+') or (FInfo[i].FIdentity='ON') or (FInfo[i].FIdentity='TRUE') then
				Result:=True
			else
				Result:=False;
end;

constructor SGTInfo.Create;
begin
inherited;
FInfo:=nil;
end;

destructor SGTInfo.Destroy;
var
	i:LongWord;
begin
if (FInfo<>nil) and (Length(FInfo)>0) then
	begin
	for i:=0 to High(FInfo) do
		FInfo[i].Destroy;
	SetLength(FInfo,0);
	end;
inherited;
end;

{=======}(*SGTBeginEnd*){=============}
{$NOTE SGTBeginEnd}

procedure SGTBeginEnd.GoRead;
var
	NI:String = '';
	GoExit:Boolean = False;
begin
repeat 
NI:=FReadClass.NextIdentifier;
if NI='END' then
	begin
	FReadClass.NextIdentifier;
	GoExit:=True;
	end;
until GoExit;
end;

procedure SGTBeginEnd.GoWrite(const FWriteClass:SGTWriteClass = nil);
var
	i:LongWord;
begin
if FParent is SGTProgram then
	begin
	FWriteClass.WriteLn(' {');
	end;
if FChunks<>nil then
	for i:=0 to High(FChunks) do
		if FChunks[i]<>nil then
			FChunks[i].GoWrite(FWriteClass);
if FParent is SGTProgram then
	begin
	FWriteClass.WriteLn('return 0 ;');
	FWriteClass.WriteLn('}');
	end;
end;

class function SGTBeginEnd.ClassName:string;inline;
begin
Result:='BEGIN END';
end;

constructor SGTBeginEnd.Create;
begin
inherited;
end;

destructor SGTBeginEnd.Destroy;
begin
inherited;
end;

{===============}(*SGTProgram*){===============}

class function SGTProgram.ClassName:string;inline;
begin
Result:='PROGRAM';
end;

constructor SGTProgram.Create;
begin
inherited;
end;

destructor SGTProgram.Destroy;
begin
inherited;
end;
{$NOTE SGTProgram}
procedure SGTProgram.GoRead;
var
	NI:String = '';
begin
repeat
NI:=FReadClass.NextIdentifier;
SourceToLog(['SGTProgram.GoRead : NextId = "',NI,'"']);
if NI='PROGRAM' then
	begin
	FName:=FReadClass.NextIdentifier;
	SourceToLog(['TSGTProgram.GoRead : Read Name Program "',FName,'"']);
	if FReadClass.NextIdentifier <> ';' then
		begin
		SourceToLog(['TSGTProgram.GoRead : After Name Must Be ";"']);
		end;
	end
else if (NI='PROCEDURE') then
	begin
	Add(SGTProcedure.Create);
	FChunks[High(FChunks)].GoRead;
	end
else if (NI='VAR') then
	begin
	repeat
	Add(SGTVar.Create);
	LastChunk.GoRead;
	until NextIdentifierIsZS or (NextIdentifierMRM='(*') or (NextIdentifierMRM='{'); 
	end
else if (NI='CONST') then
	begin
	repeat
	Add(SGTConst.Create);
	LastChunk.GoRead;
	until NextIdentifierIsZS; 
	end
else if NI='USES' then
	begin
	repeat
	NI:=FReadClass.NextIdentifier;
	(FParent as TSGTranslater).GoFindAndReadUnit(NI);
	Add(SGTModule.Create);
	LastChunk.FName:=NI;
	NI:=FReadClass.NextIdentifier;
	until NI=';';
	end
else if NI='BEGIN' then
	begin 
	Add(SGTBeginEnd.Create);
	FChunks[High(FChunks)].GoRead;
	NI:='.';
	end
else if NI='{' then
	begin
	Add(SGTComment.Create);
	FChunks[High(FChunks)].GoRead;
	end;
until (NI='.') or (NI='END');
end;

procedure SGTProgram.GoWrite(const FWriteClass:SGTWriteClass = nil);
var
	FStream:SGTWriteClass = nil;
	i:LongWord;
begin
SourceToLog(['SGTProgram.GoWrite : Beginning']);
FStream:=SGTWriteClass.Create(OutWay+FWay+FName+'.cpp');
FStream.WriteLn('//'+FName+'.pas');
FStream.Writeln('#include "SaGeHeader.h"');
if FChunks<>nil then
	for i:=0 to High(FChunks) do
		begin
		if FChunks[i] is SGTBeginEnd then
			begin
			FStream.Write('int main ( int argc, char * argv [] )')
			end;
		FChunks[i].GoWrite(FStream);
		if not (((i<High(FChunks)) and (FChunks[i] is SGTModule) and (FChunks[i+1] is SGTModule))) then
			FStream.WriteLn('');
		end;
FStream.Destroy;
end;

{=========}(*SGTUnit*){=========}
class function SGTUnit.ClassName:string;inline;
begin
Result:='UNIT';
end;

constructor SGTUnit.Create;
begin
inherited;
FPlace:=SGTUHeader;
end;

destructor SGTUnit.Destroy;
begin
inherited;
end;

{$NOTE SGTUnit}
procedure SGTUnit.GoRead;
var
	NI:String = '';
	ToExit:Boolean = False;
begin
NI:=FReadClass.NextIdentifier;
FName := FReadClass.NextIdentifier;
NI:=FReadClass.NextIdentifier;
repeat 
NI:=FReadClass.NextIdentifier;
if NI = 'INTERFACE' then
	begin
	FPlace := SGTUHeader;
	end
else if (NI='PROCEDURE') then
	begin
	Add(SGTProcedure.Create);
	FChunks[High(FChunks)].FPlace:=FPlace;
	FChunks[High(FChunks)].GoRead;
	end
else if (NI='VAR') then
	begin
	repeat
	Add(SGTVar.Create);
	LastChunk.FPlace:=FPlace;
	LastChunk.GoRead;
	until NextIdentifierIsZS; 
	end
else if (NI='CONST') then
	begin
	repeat
	Add(SGTConst.Create);
	LastChunk.FPlace:=FPlace;
	LastChunk.GoRead;
	until NextIdentifierIsZS; 
	end
else if NI='USES' then
	begin
	repeat
	NI:=FReadClass.NextIdentifier;
	(FParent as TSGTranslater).GoFindAndReadUnit(NI);
	Add(SGTModule.Create);
	LastChunk.FName:=NI;
	LastChunk.FPlace:=FPlace;
	NI:=FReadClass.NextIdentifier;
	until NI=';';
	end
else if NI = 'IMPLEMENTATION' then
	begin
	FPlace:=SGTUCPP;
	end
else if NI = 'END' then
	ToExit:=True;
until ToExit;
FPlace:=SGTUUnsigned;
end;

procedure SGTUnit.GoWrite(const FWriteClass:SGTWriteClass = nil);
var
	FStream:SGTWriteClass = nil;
	i:LongWord;
begin

FStream:=SGTWriteClass.Create(OutWay+FWay+FName+'.h');
FStream.WriteLn('//Header (Interface) of "'+FName+'.pas"');
FStream.WriteLn('#ifndef '+FName+'_included');
FStream.WriteLn('#define '+FName+'_included');
FStream.Writeln('#include "SaGeHeader.h"');
if FChunks<>nil then
	for i:=0 to High(FChunks) do
		if FChunks[i].FPlace=SGTUHeader then
			begin
			FChunks[i].GoWrite(FStream);
			FStream.WriteLn('');
			end;
FStream.WriteLn('#endif');
FStream.Destroy;

FStream:=SGTWriteClass.Create(OutWay+FWay+FName+'.cpp');
FStream.WriteLn('//CPP (Implementation) of "'+FName+'.pas"');
FStream.WriteLn('#include "'+FName+'.h"');
if FChunks<>nil then
	for i:=0 to High(FChunks) do
		if FChunks[i].FPlace=SGTUCPP then
			begin
			FChunks[i].GoWrite(FStream);
			FStream.WriteLn('');
			end;
FStream.Destroy;
end;

{=============}(*SGTReadClassComponent*){===========}

procedure SGTReadClassComponent.SourceToLog(const Ar:packed array of const);
var
	OutString:String;
	I:LongWord;
begin
OutString:='';
OutString:=SGGetStringFromConstArray(Ar);
SGLog.Source(['[ ',FReadClass.StringInfo,' ] ',OutString]);
SetLength(OutString,0);
end;

function SGTReadClassComponent.NextIdentifierMRM:string;
begin
FReadClass.Member;
Result:=FReadClass.NextIdentifier;
FReadClass.ReMember;
end;


class function SGTReadClassComponent.ClassName:string;inline;
begin
Result:='READ CLASS COMPONENT';
end;

constructor SGTReadClassComponent.Create;
begin
inherited;
FReadClass:=nil;
end;

destructor SGTReadClassComponent.Destroy;
begin
if FReadClass<>nil then
	if (FParent is SGTReadClassComponent) and ((FParent as SGTReadClassComponent).FReadClass=FReadClass) then else 
		FReadClass.Destroy;
inherited;
end;

function SGTReadClassComponent.NextIdentifierIsZS:Boolean;
begin
FReadClass.Member;
Result:= IsZS([
	'TYPE',  'LABEL',  'INTERFACE','IMPLEMENTATION','BEGIN'    ,'END'  ,'VAR',
	'PUBLIC','PRIVATE','PUBLISHED','FUNCTION'      ,'PROCEDURE','CLASS',
	'DESTRUCTOR','CONSTRUCTOR','PROPERTY','CONST','FOR','DO','THEN','ELSE','IF','TO','DOWNTO'],FReadClass.NextIdentifier);
FReadClass.ReMember;
end;
{==========}(*SGTComponent*){==========}

function SGTComponent.GetOutWay:string;
begin
if FParent<>nil then
	Result:=FParent.OutWay
else
	Result:='';
end;

function SGTComponent.LastChunk:SGTComponent;inline;
begin
if (FChunks=nil) or (Length(FChunks)=0) then
	Result:=nil
else
	Result:=FChunks[High(FChunks)];
end;

function SGTComponent.TransliatorClass:SGTranslater;
begin
if Self is  SGTranslater then
	Result:=(Self as SGTranslater)
else
	if FParent is SGTranslater then
		Result:=(FParent as SGTranslater)
	else
		Result:=FParent.TransliatorClass;
end;

function SGTComponent.IsZS(const Ar:array of const;const Sl:String):Boolean;
var
	i:LongWord;
begin
Result:=False;
if High(Ar)>=0 then 
	begin
	for i := 0 to High(ar) do
		case ar[i].vtype of
		vtString: 
			if SGUpCaseString(ar[i].vstring^) = SGUpCaseString(Sl) then
				begin
				Result:=True;
				Exit;
				end;
		vtAnsiString: 
			begin
			if SGUpCaseString((AnsiString(ar[i].vpointer))) = SGUpCaseString(Sl) then
				begin
				Result:=True;
				Exit;
				end;
			end;
		end;
	end;
end;

procedure SGTComponent.Add(const NewComponent:SGTComponent);
begin
if (FChunks=nil) then
	SetLength(FChunks,1)
else
	SetLength(FChunks,Length(FChunks)+1);
FChunks[High(FChunks)]:=NewComponent;
FChunks[High(FChunks)].FParent:=Self;
if (Self is SGTReadClassComponent) and (NewComponent is SGTReadClassComponent) then
	(NewComponent as SGTReadClassComponent).FReadClass:=(Self as SGTReadClassComponent).FReadClass;
end;

class function SGTComponent.ClassName:string;inline;
begin
Result:='COMPONENT';
end;

constructor SGTComponent.Create;
begin
inherited;
FPlace:=SGTUUnsigned;
FParent:=nil;
FName:='';
end;

destructor SGTComponent.Destroy;
var
	i:LongWord;
begin
if FChunks<>nil then
	begin
	for i:=0 to High(FChunks) do
		FChunks[i].Destroy;
	SetLength(FChunks,0);
	end;
inherited;
end;

procedure SGTComponent.GoRead;
begin
end;

procedure SGTComponent.GoWrite(const FWriteClass:SGTWriteClass = nil);
begin
end;

{==========}(*SGTranslater*){==========}

function TSGTranslater.GetOutWay:string;
begin
Result:=FOutWay;
end;

procedure TSGTranslater.GoWrite(const FWriteClass:SGTWriteClass = nil);
var 
	i:LongWord;
	FSGH:SGTWriteClass = nil;
begin
SGReleazeFileWay(FOutWay);

FSGH:=SGTWriteClass.Create(FOutWay+'SaGeHeader.h');
FSGH.WriteLn('#ifndef sageheader_included');
FSGH.WriteLn('#define sageheader_included');
FSGH.WriteLn('#include <iostream>');
FSGH.WriteLn('#include <cstring>');
FSGH.WriteLn('using namespace std;');
FSGH.WriteLn('typedef signed long int LONGINT ;');
FSGH.WriteLn('typedef signed int INTEGER ;');
FSGH.WriteLn('typedef float SINGLE ;');
FSGH.WriteLn('typedef double REAL ;');
FSGH.WriteLn('typedef unsigned short BYTE ;');
FSGH.WriteLn('typedef signed short SHORTINT ;');
FSGH.WriteLn('typedef signed long long int INT64 ;');
FSGH.WriteLn('typedef unsigned char CHAR ;');
FSGH.WriteLn('typedef const char* STRING ;');
FSGH.WriteLn('typedef bool BOOLEAN ;');
FSGH.WriteLn('typedef const bool LONGBOOL ;');
FSGH.WriteLn('#define true TRUE');
FSGH.WriteLn('#define false FALSE');
FSGH.WriteLn('#endif');
FSGH.Destroy;

if FChunks<>nil then
for i:=0 to High(FChunks) do
	begin
	if (FChunks[i]<>nil) then
		begin
		FChunks[i].GoWrite{(FWriteClass)};
		end;
	end;
end;

function TSGTranslater.GoFindAndReadUnit(const VWay:string):Boolean;

function ExistsUnit:Boolean;
var
	i:LongWord;
begin
Result:=False;
if FChunks<>nil then
	for i:=0 to High(FChunks) do
		if FChunks[i].FName=VWay then
			begin
			Result:=True;
			Exit;
			end;
end;

begin
Result:=False;
if ExistsUnit then Exit;
SGLog.Source(['TSGTranslater.GoFindAndReadUnit : Create Unit Chunck "',Way,'"']);
SetLength(FChunks,Length(FChunks)+1);
FChunks[High(FChunks)]:=SGTUnit.Create;
FChunks[High(FChunks)].FName:=Way;
(FChunks[High(FChunks)] as SGTReadClassComponent).FReadClass:=SGTReadClass.Create(SGTRead.Create(Way+'.pas'));
FChunks[High(FChunks)].FParent:=Self;
SGLog.Source(['TSGTranslater.GoRead : Go Read "',Length(FChunks),'" Chunck "',Way,'"']);
FChunks[High(FChunks)].GoRead;
Result:=True;
end;

function TSGTranslater.FileType(const VWay:string):string;
var
	RC:SGTReadClass = nil;
begin
RC:=SGTReadClass.Create;
RC.Add(SGTRead.Create(VWay));
Result:=SGUpCaseString(RC.NextIdentifier);
RC.Destroy;
if (Result='VAR') or (Result='USES') or 
	(Result='TYPE') or (Result='BEGIN') or(Result='LABEL') or
	(Result='PROCEDURE') or (Result='FUNCTION') then
		Result:='PROGRAM';
if (Result<>'PROGRAM') and
	(Result<>'UNIT') and 
	(Result<>SGUpCaseString('library')) then
		Result:='';
end;

procedure TSGTranslater.GoRead;
var
	FT:String = '';
	I,ii:LongWord;
var
	MW:String = '';
	WasInCmd:Boolean = False;
var
	AnyError : TSGBool = False;
begin
if SGUpCaseString(FObject)='CMD' then
	begin
	SGLog.Source(['TSGTranslater.GoRead : Start Reading (Cmd Type)']);
	if (FParams <> nil) and (Length(FParams) > 0) then
	for ii:=0 to High(FParams) do
		begin
		FT:=SGUpCaseString(FParams[ii]);
		if (FT[1]<>'-') then
			begin
			AnyError := True;
			Writeln('Befor command "',FT,'" must be "-".');
			SGLog.Source(['TSGTranslater.GoRead : ','Befor command "',FT,'" must be "-".']);
			end
		else if Length(FT)<3 then
			begin
			AnyError := True;
			Writeln('Error syntax command "',FT,'". (Length>3)');
			SGLog.Source(['TSGTranslater.GoRead : ','Error syntax command "',FT,'" (Length>3).']);
			end
		else
			begin
			if (FT[2]='P') and (FT[3]='M') then
				begin
				MW:='';
				for i:=4 to Length(FT) do
					MW+=FT[i];
				end
			else if (FT[2]='O') and (FT[3]='W') then
				begin
				FOutWay:='';
				for i:=4 to Length(FT) do
					FOutWay+=FT[i];
				if not (FOutWay[Length(FOutWay)] in [UnixSlash,WinSlash]) then
					FOutWay+=Slash;
				end
			else if (FT[2]='P') and ((FT[3]='P') or (FT[3]='U') or (FT[3]='L')) then
				begin
				FObject:='';
				for i:=4 to Length(FT) do
					FObject+=FT[i];
				end
			else 
				begin
				AnyError := True;
				Writeln('Error syntax command "',FT,'".');
				SGLog.Source(['TSGTranslater.GoRead : ','Error syntax command "',FT,'".']);
				end;
			end;
		end;
	WasInCmd:=True;
	end;
if AnyError then
	begin
	SGHint(['Help:']);
	SGHint(['  Use -pm(%path_makefile) for set makefile path.']);
	SGHint(['  Use -ow(%out_path) for set out path.']);
	SGHint(['  Use -pp(%object_path) for set object path to translate.']);
	SGHint(['  Use -pu(%object_path) for set object path to translate.']);
	SGHint(['  Use -pl(%object_path) for set object path to translate.']);
	Halt(0);
	end;
if (SGGetFileExpansion(SGUpCaseString(FObject))='PAS') or (SGGetFileExpansion(SGUpCaseString(FObject))='PP') then
	begin
	SGLog.Source(['TSGTranslater.GoRead : Start Reading (Not Makefile Type)']);
	FT:=FileType(FObject);
	if FT='' then
		begin
		AnyError := True;
		SGLog.Source(['TSGTranslater.GoRead : Error Getting File Type "',FObject,'"']);
		end
	else
		begin
		SGLog.Source(['TSGTranslater.GoRead : Create Chunck "',FT,'"']);
		SetLength(FChunks,1);
		if FT='PROGRAM' then
			FChunks[0]:=SGTProgram.Create;
		if FT='UNIT' then
			FChunks[0]:=SGTUnit.Create;
		if FT=SGUpCaseString('library') then
			;//FChunks[0]:=SGTUnit.Create;
		(FChunks[0] as SGTReadClassComponent).FReadClass:=SGTReadClass.Create(SGTRead.Create(FObject));
		FChunks[0].FParent:=Self;
		SGLog.Source(['TSGTranslater.GoRead : Go Read First Chunck "',FT,'"']);
		FChunks[0].GoRead;
		end;
	end
else  if (not WasInCmd) or (WasInCmd and (MW='')) then
	begin
	AnyError := True;
	SGLog.Source(['TSGTranslater.GoRead : Don''t know what a you doing!']);
	if WasInCmd then
		WriteLn('TSGTranslater.GoRead : Don''t know what a you doing!');
	end
else {= Makefile}
	begin
	if WasInCmd then
		FObject:=MW;
	SGLog.Source(['TSGTranslater.GoRead : Start Reading (Makefile Type)']);
	if (SGGetFileName(FObject)='') and (SGGetFileExpansion(FObject)='') then
		begin
		FObject+='Makefile';
		end;
	if SGFileExists(FObject) then
		begin
		SGLog.Source(['TSGTranslater.GoRead : Finded makefile.']);
		end
	else
		begin
		SGLog.Source(['TSGTranslater.GoRead : Don''t find makefile.']);
		if WasInCmd then
			WriteLn('Don''t find makefile..');
		end;
	end;
end;

class function SGTranslater.Create(const VWay:String):SGTranslater;overload;
begin
Result:=SGTranslater.Create;
Result.FObject:=VWay;
end;

procedure SGTranslater.GoTranslate;inline;
begin
GoRead;
GoWrite;
end;

class function SGTranslater.ClassName:string;inline;
begin
Result:='TRANSLATER';
end;

constructor SGTranslater.Create;
begin
inherited;
FWays:=nil;
FChunks:=nil;
FOutWay:='';
end;

destructor SGTranslater.Destroy;
begin
inherited;
end;

{=====}(*SGTRead*){=====}

function SGTRead.StringInfo:String;
begin
Result:='"'+FWay+'":'+SGStr(FLine)+'x'+SGStr(FColumn)+'';
end;

procedure SGTRead.Member;
begin
if (FMember<>nil) then
	SetLength(FMember,Length(FMember)+1)
else
	SetLength(FMember,1);
FMember[High(FMember)].FPosition:=FStream.Position;
FMember[High(FMember)].FLine:=FLine;
FMember[High(FMember)].FColumn:=FColumn;
end;

procedure SGTRead.ReMember;
begin
if (FStream<>nil) and (FMember<>nil) and (Length(FMember)>=1) then
	begin
	FStream.Position:=FMember[High(FMember)].FPosition;
	FLine:=FMember[High(FMember)].FLine;
	FColumn:=FMember[High(FMember)].FColumn;
	SetLength(FMember,Length(FMember)-1);
	end;
end;

function SGTRead.ReadChar:Char;
begin
Result:=#0;
if FStream.Position<FStream.Size then
	begin
	FStream.ReadBuffer(Result,1);
	if Result=#13 then
		begin
		FLine+=1;
		FColumn:=0;
		end
	else
		if Result<>#10 then
			FColumn+=1;
	end
else
	SGLog.Source('SGTRead.ReadChar : Stream.Position = Stream.Size');
end;

class function SGTRead.Create(const Way:String):SGTRead;overload;
begin
Result:=SGTRead.Create;
Result.FWay:=Way;
end;

constructor SGTRead.Create;overload;
begin
inherited;
FWay:='';
FStream:=nil;
end;

destructor SGTRead.Destroy;
begin
if FStream<>nil then
	begin
	FStream.Destroy;
	FStream:=nil;
	end;
inherited;
end;

function SGTRead.NextIdentifier:string;
begin
if FStream=nil then
	if FWay<>'' then
		FStream:=TFileStream.Create(FWay,fmOpenRead)
	else
		begin
		Result:='';
		Exit;
		end;
if FStream.Position=FStream.Size then
	begin
	Result:='';
	Exit;
	end;
Result:=SGUpCaseString(ReadCircle());
//SourceToLog(['Translator : Low  Identity of "',FWay,'" is "',Result,'"']);
end;

procedure SGTRead.MovePos(const I:Int64);
begin
FStream.Position:=FStream.Position+I;
end;

function SGTRead.ReadCircle:string;
var
	C:Char;
	Razd:Set Of Char = ['''','#','@','{','}','[',']','$','(',')','-','+','=',':',';','.',',','*'];
	Probel:Set Of Char = [' ',#13,#10,'	'];
	ExitCircle:Boolean = False;
begin
Result:='';
while not ExitCircle do
	begin
	C:=ReadChar;
	if (C in Probel) and (Result<>'') then
		ExitCircle:=True
	else if (C in Probel) and (Result='') then
	else if (C in Razd) then
		begin
		if Result='' then
			Result:=C
		else
			begin
			MovePos(-1);
			end;
		ExitCircle:=True;
		end
	else 
		begin
		Result+=C;
		end;
	end;

if Result='>' then
	begin
	FStream.ReadBuffer(C,SizeOf(C));
	if C='>' then
		Result:='>>'
	else
		begin
		MovePos(-1);
		Result:='>';
		end;
	end;

if Result='<' then
	begin
	FStream.ReadBuffer(C,SizeOf(C));
	if C='>' then
		Result:='<>'
	else
		begin
		MovePos(-1);
		Result:='<';
		end;
	end;

if Result='<' then
	begin
	FStream.ReadBuffer(C,SizeOf(C));
	if C='<' then
		Result:='<<'
	else
		begin
		MovePos(-1);
		Result:='<';
		end;
	end;

if Result='<' then
	begin
	FStream.ReadBuffer(C,SizeOf(C));
	if C='=' then
		Result:='<='
	else
		begin
		MovePos(-1);
		Result:='<';
		end;
	end;

if Result='>' then
	begin
	FStream.ReadBuffer(C,SizeOf(C));
	if C='=' then
		Result:='>='
	else
		begin
		MovePos(-1);
		Result:='>';
		end;
	end;

if Result=':' then
	begin
	FStream.ReadBuffer(C,SizeOf(C));
	if C='=' then
		Result:=':='
	else
		begin
		MovePos(-1);
		Result:=':';
		end;
	end;

if Result='(' then
	begin
	FStream.ReadBuffer(C,SizeOf(C));
	if C='*' then
		Result:='(*'
	else
		begin
		MovePos(-1);
		Result:='(';
		end;
	end;

if Result='*' then
	begin
	FStream.ReadBuffer(C,SizeOf(C));
	if C=')' then
		Result:='*)'
	else
		begin
		MovePos(-1);
		Result:='*';
		end;
	end;

if Result='*' then
	begin
	FStream.ReadBuffer(C,SizeOf(C));
	if C='*' then
		Result:='**'
	else
		begin
		MovePos(-1);
		Result:='*';
		end;
	end;

if Result='{' then
	begin
	FStream.ReadBuffer(C,SizeOf(C));
	if C='$' then
		Result:='{$'
	else
		begin
		MovePos(-1);
		Result:='{';
		end;
	end;
end;

{=============}(*TSGTReadClass*){=============}

function TSGTReadClass.StringInfo:String;
begin
if (FFiles=nil) or (Length(FFiles)=0) then
	Result:=''
else
	Result:=FFiles[High(FFiles)].StringInfo;
end;

procedure TSGTReadClass.UnReadComments;
var
	Quantity:LongWord = 1;
	C:Char = #0;
begin
SGLog.Source(['TSGTReadClass.UnReadComments']);
while Quantity>0 do
	begin
	C:=FFiles[High(FFiles)].ReadChar;
	if C='{' then
		Quantity+=1
	else if C='}' then
		Quantity-=1;
	end;
end;

function TSGTReadClass.ReadChar:Char;
begin
Result:=FFiles[High(FFiles)].ReadChar;
end;

function TSGTReadClass.NextIdentifier:String;
var
	Id1:String;
	Id2:String;

procedure Obhod;
var
	ii:LongWord;
	Identity3:String;
begin
SGLog.Source('TSGTReadClass.NextIdentifier.Obhod');
ii:=1;
repeat
Identity3:=FFiles[High(FFiles)].NextIdentifier;
if Identity3='{$' then
	begin
	Identity3:=FFiles[High(FFiles)].NextIdentifier;
	if (Identity3='IFDEF') or (Identity3='IF') or (Identity3='IFOPT') then
		begin ii+=1; UnReadComments; end
	else if (Identity3='ENDIF') then
		begin 
		ii-=1; 
		UnReadComments;
		if ii=0 then
			FInfo.DeleteIf;
		end
	else if (Identity3 = 'ELSE') and (ii=1) then
		begin
		UnReadComments;
		ii:=0;
		end;
	end;
until (ii=0);
end;

procedure Include;
var
	Way:string;
	C:Char;
begin
Way:='';
repeat 
C:=ReadChar;
if C<>'}' then
	if (C in [' ',#13,#10,'	']) then
		if Way<>'' then
			begin
			UnReadComments;
			C:='}';
			end
		else
	else
		Way+=C;
until C='}';
SetLength(FFiles,Length(FFiles)+1);
FFiles[High(FFiles)]:=SGTRead.Create(Way);
end;

begin
Result:='';
if (FFiles=nil) or (Length(FFiles)=0) then
	SGLog.Source('TSGTReadClass.NextIdentifier : Quantity Files = 0')
else
	begin
	Result:=FFiles[High(FFiles)].NextIdentifier;
	if ((not FWithComments) and (Result='{')) or
		((not FWithDirictives) and (Result='{$'))then
		begin
		UnReadComments;
		Result:=NextIdentifier();
		end
	else
		if ((FWithDirictives) and (Result='{$')) then
			begin
			Id1:=FFiles[High(FFiles)].NextIdentifier;
			if Id1='ELSE' then
				begin
				UnReadComments;
				Obhod;
				end
			else if Id1='ENDIF' then
				begin
				UnReadComments;
				FInfo.DeleteIf;
				end
			else if Id1='IFDEF' then
				begin
				Id2:=FFiles[High(FFiles)].NextIdentifier;
				UnReadComments;
				FInfo.Add(SGTInfoChunk.Create('IF',''));
				if not FInfo.Defined(Id2) then
					Obhod;
				end
			else if Id1='I' then
				begin
				ReadChar;
				Include;
				end
			else if Id1='DEFINE' then
				begin
				Id2:=FFiles[High(FFiles)].NextIdentifier;
				FInfo.Add(SGTInfoChunk.Create('DEFINE',Id2));
				UnReadComments;
				end
			else if Id1='MODE' then
				begin
				Id2:=FFiles[High(FFiles)].NextIdentifier;
				FInfo.Add(SGTInfoChunk.Create('MODE',Id2));
				UnReadComments;
				end
			else if Id1='UNDEF' then
				begin
				Id2:=FFiles[High(FFiles)].NextIdentifier;
				FInfo.Add(SGTInfoChunk.Create('UNDEF',Id2));
				UnReadComments;
				end
			else if Id1='ASMMODE' then
				begin
				Id2:=FFiles[High(FFiles)].NextIdentifier;
				FInfo.Add(SGTInfoChunk.Create('ASMMODE',Id2));
				UnReadComments;
				end
			else if Id1='H' then
				begin
				Id2:=FFiles[High(FFiles)].NextIdentifier;
				FInfo.Add(SGTInfoChunk.Create('H',Id2));
				UnReadComments;
				end
			else
				UnReadComments;
			Result:=Self.NextIdentifier();
			end;
	end;
//SourceToLog(['Translator : High Identity of "',FFiles[High(FFiles)].FWay,'" is "',Result,'"']);
end;

class function TSGTReadClass.Create(const TRead:SGTRead):SGTReadClass;overload;
begin
Result:=TSGTReadClass.Create;
Result.Add(TRead);
end;

procedure TSGTReadClass.Add(const TRead:SGTRead);
begin
if FFiles=nil then
	SetLength(FFiles,1)
else
	SetLength(FFiles,Length(FFiles)+1);
FFiles[High(FFiles)]:=TRead;
end;

destructor TSGTReadClass.Destroy;
var
	i:LongWord;
begin
if FFiles<>nil then
	begin
	for i:=0 to High(FFiles) do
		FFiles[i].Destroy;
	SetLength(FFiles,0);
	FFiles:=nil;
	end;
FInfo.Destroy;
inherited;
end;

procedure TSGTReadClass.Member;
begin
if (FFiles<>nil) and (Length(FFiles)>0) then
	FFiles[High(FFiles)].Member;
end;

procedure TSGTReadClass.ReMember;
begin
if (FFiles<>nil) and (Length(FFiles)>0) then
	FFiles[High(FFiles)].ReMember;
end;

constructor TSGTReadClass.Create;
begin
inherited;
FFiles:=nil;
FInfo:=SGTInfo.Create;
FWithComments:=True;
FWithDirictives:=True;
end;

end.
