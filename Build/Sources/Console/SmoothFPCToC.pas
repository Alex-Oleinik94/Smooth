{$INCLUDE Smooth.inc}

unit SmoothFPCToC;

interface

uses
	 Classes
	
	,SmoothStringUtils
	,SmoothBase
	,SmoothConsoleHandler
	;

type
	STranslater=class;
	
	STInfoChunk=class 
			public
		constructor Create(const Dir,Id:String);
			public
		FDirictive,FIdentity:String; 
		end;
	
	STInfo=class
			public
		constructor Create;
		destructor Destroy;override;
			public
		FInfo:packed array of STInfoChunk;
			public
		function Defined(const Id:String):Boolean;
		function Mode:String;
		function AsmMode:String;
		function H:Boolean;
		procedure Add(const NewInfo:STInfoChunk);
		procedure DeleteIf;
		end;
	
	STRead=class
			public
		constructor Create;overload;
		destructor Destroy;override;
		class function Create(const Way:String):STRead;overload;
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
	TSTRead=STRead;
	
	STReadClass=class
			public
		constructor Create;overload;
		destructor Destroy;override;
		class function Create(const TRead:STRead):STReadClass;overload;
		procedure Add(const TRead:STRead);
		function NextIdentifier:String;
		procedure UnReadComments;
		function ReadChar:Char;
		procedure Member;
		procedure ReMember;
		function StringInfo:String;
			public
		FFiles:packed array of STRead;
		FInfo:STInfo;
		FWithComments:Boolean;
		FWithDirictives:Boolean;
		end;
	TSTReadClass=STReadClass;
	
	STWriteClass=class
			public
		constructor Create(const Way:String);
		destructor Destroy;override;
		procedure Write(const s:String);
		procedure WriteLn(const s:string);
			public
		FStream:TFileStream;
		end;
	
	STUPlace=(STUUnsigned,STUHeader,STUCPP);
	STComponent=class
			public
		class function ClassName:string;virtual;
		constructor Create;virtual;
		destructor Destroy;override;
		procedure GoRead;virtual;
		procedure GoWrite(const FWriteClass:STWriteClass = nil);virtual;
		function IsZS(const Ar:array of const;const Sl:String):Boolean;
		procedure Add(const NewComponent:STComponent);
		function TransliatorClass:STranslater;
		function LastChunk:STComponent;inline;
			private
		function GetOutWay:string;virtual;
			public
		FChunks:packed array of STComponent;
		FPlace:STUPlace;
		FParent:STComponent;
		FName:String;
		FWay:String;
			public
		property Way:string read FWay write FWay;
		property OutWay:string read GetOutWay;
		end;
	TSTComponent=STComponent;
	
	STModule=class(STComponent) 
		class function ClassName:string;override;
		procedure GoWrite(const FWriteClass:STWriteClass = nil);override;
		end;
	
	STReadClassComponent=class(STComponent)
			public
		class function ClassName:string;override;
		constructor Create;override;
		destructor Destroy;override;
		function NextIdentifierIsZS:Boolean;
		function NextIdentifierMRM:string;
		procedure SourceToLog(const Ar:packed array of const);
			public
		FReadClass:STReadClass;
		end;
	
	STComment=class(STReadClassComponent)
			public
		class function ClassName:string;override;
		constructor Create;override;
		destructor Destroy;override;
		procedure GoRead;override;
		procedure GoWrite(const FWriteClass:STWriteClass = nil);override;
			public
		FComment:String;
		end;
	TSTComment = STComment;
	
	STExpression = class(STReadClassComponent)
			public
		class function ClassName:string;override;
		constructor Create;override;
		destructor Destroy;override;
		procedure GoRead;override;
		procedure GoWrite(const FWriteClass:STWriteClass = nil);override;
		end;
	TSTExpression = STExpression;
	
	STVar=class(STReadClassComponent)
			public
		class function ClassName:string;override;
		constructor Create;override;
		destructor Destroy;override;
		procedure GoRead;override;
		procedure GoWrite(const FWriteClass:STWriteClass = nil);override;
			public
		FVariables:packed array of String;
		FType:String;
		FExpression:STExpression;
		end;
	TSTVar = STVar;
	
	STConst=class(STReadClassComponent)
		public
		class function ClassName:string;override;
		constructor Create;override;
		destructor Destroy;override;
		procedure GoRead;override;
		procedure GoWrite(const FWriteClass:STWriteClass = nil);override;
			public
		FConst:String;
		FType:String;
		FExpression:STExpression;
		end;
	
	STProcedure = class(STReadClassComponent)
			public
		class function ClassName:string;override;
		constructor Create;override;
		destructor Destroy;override;
		procedure GoRead;override;
		procedure GoWrite(const FWriteClass:STWriteClass = nil);override;
			public
		FParametrs:packed array of
			packed record 
			FType,FTypeType:String;
			FExpression:STExpression;
			FNames:packed array of
				String;
			end;
		end;
	TSTProcedure = STProcedure;
	
	STUnit=class(STReadClassComponent)
			public
		class function ClassName:string;override;
		constructor Create;override;
		destructor Destroy;override;
			public
		procedure GoRead;override;
		procedure GoWrite(const FWriteClass:STWriteClass = nil);override;
		end;
	TSTUnit=STUnit;
	
	TSTProgram=class(STReadClassComponent)
			public
		class function ClassName:string;override;
		constructor Create;override;
		destructor Destroy;override;
			public
		procedure GoRead;override;
		procedure GoWrite(const FWriteClass:STWriteClass = nil);override;
		end;
	STProgram=TSTProgram;
	
	STBeginEnd=class(STReadClassComponent)
			public
		class function ClassName:string;override;
		constructor Create;override;
		destructor Destroy;override;
		procedure GoRead;override;
		procedure GoWrite(const FWriteClass:STWriteClass = nil);override;
		end;
	TSTBeginEnd = STBeginEnd;
	
	STranslater=class(STComponent)
			public
		class function ClassName:string;override;
		constructor Create;override;overload;
		destructor Destroy;override;
		class function Create(const VWay:String):STranslater;overload;
			public
		FObject:string;
		FWays:packed array of String;
		FOutWay:string;
		FParams : TSConsoleHandlerParams;
			private
		function GetOutWay:string;override;
			public
		procedure GoRead;override;
		procedure GoTranslate;inline;
		procedure GoWrite(const FWriteClass:STWriteClass = nil);override;
		function FileType(const VWay:string):string;
		function GoFindAndReadUnit(const VWay:string):Boolean;
			public
		property Params : TSConsoleHandlerParams read FParams write FParams;
		end;
	TSTranslater=STranslater;

implementation

uses
	 SmoothLog
	,SmoothFileUtils
	;
{==============}(*STExpression*){==============}

class function STExpression.ClassName:string;
begin
Result:='EXPRESSION';
end;

constructor STExpression.Create;
begin
inherited;
end;

destructor STExpression.Destroy;
begin
inherited;
end;

procedure STExpression.GoRead;
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
SourceToLog(['STExpression.GoRead : Beginning']);
repeat
NI:=FReadClass.NextIdentifier;
Add(STComment.Create);
SourceToLog(['STExpression.GoRead : Adding "',NI,'"']);
LastChunk.FName:=NI;
until hare;
SourceToLog(['STExpression.GoRead : End']);
end;

procedure STExpression.GoWrite(const FWriteClass:STWriteClass = nil);
var
	I:LongWord;
begin
if FChunks<>nil then
	for i:=0 to High(FChunks) do
		FWriteClass.Write(FChunks[i].FName);
end;

{==========}(*STConst*){=================}
class function STConst.ClassName:string;
begin
Result:='CONST';
end;

constructor STConst.Create;
begin
inherited;
FConst:='';
FType:='';
FExpression:=nil;
end;

destructor STConst.Destroy;
begin
if FExpression<>nil then
	FExpression.Destroy;
inherited;
end;

procedure STConst.GoRead;
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

FExpression:=STExpression.Create;
FExpression.FParent:=Self;
FExpression.FReadClass:=FReadClass;
FExpression.GoRead;

FReadClass.NextIdentifier;
end;

procedure STConst.GoWrite(const FWriteClass:STWriteClass = nil);
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

{============}(*STWriteClass*){============}

constructor STWriteClass.Create(const Way:String);
begin
inherited Create;
FStream:=TFileStream.Create(Way,fmCreate);
end;

destructor STWriteClass.Destroy;
begin
if FStream<>nil then
	FStream.Destroy;
inherited;
end;

procedure STWriteClass.Write(const s:String);
var
	P:PChar;
begin
P:=SStringToPChar(s);
FStream.WriteBuffer(P[0],Length(s));
end;

procedure STWriteClass.WriteLn(const s:string);
begin
Write(s+#13+#10);
end;

{=============}(*STModule*){=============}
class function STModule.ClassName:string;
begin
Result:='MODULE';
end;

procedure STModule.GoWrite(const FWriteClass:STWriteClass = nil);
begin
FWriteClass.WriteLn('#include "'+FName+'.h"');
end;

{============}(*STProcedure*){============}
class function STProcedure.ClassName:string;
begin
Result:='PROCEDURE';
end;

constructor STProcedure.Create;
begin
inherited;
FParametrs:=nil;
end;

destructor STProcedure.Destroy;
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
{$Note STProcedure}
procedure STProcedure.GoRead;
var
	NI:String = '';
begin
SourceToLog(['STProcedure.GoRead : Begin read header procedure']);
FName:=FReadClass.NextIdentifier;
SourceToLog(['STProcedure.GoRead : Name procedure is "',FName,'"']);
NI:=FReadClass.NextIdentifier;
if NI='(' then
	begin
	NI:=FReadClass.NextIdentifier;
	while NI<>')' do
		begin
		SourceToLog(['STProcedure.GoRead : Begin to read parametr procedure "',FName,'"']);
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
			SourceToLog(['STProcedure.GoRead : type of type "',Length(FParametrs),'" is "',NI,'"']);
			FParametrs[High(FParametrs)].FTypeType:=NI;
			NI:=FReadClass.NextIdentifier;
			end;
		while NI<>':' do
			begin
			SourceToLog(['STProcedure.GoRead : Begin to read variable parametr procedure "',FName,'"']);
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
			FParametrs[High(FParametrs)].FExpression:=STExpression.Create;
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
SourceToLog(['STProcedure.GoRead : End read header procedure']);
if FPlace<>STUHeader then
	begin
	SourceToLog(['STProcedure.GoRead : Begin to read chuncks procedure "',FName,'"']);
	repeat
	NI:=FReadClass.NextIdentifier;
	if NI='PROCEDURE' then
		begin
		Add(STProcedure.Create);
		LastChunk.GoRead;
		end
	else if (NI='VAR') then
		begin
		repeat
		Add(STVar.Create);
		LastChunk.GoRead;
		until NextIdentifierIsZS;
		end
	else if (NI='CONST') then
		begin
		repeat
		Add(STConst.Create);
		LastChunk.GoRead;
		until NextIdentifierIsZS; 
		end
	else if NI='{' then
		begin
		Add(STComment.Create);
		FChunks[High(FChunks)].GoRead;
		end
	else if NI='BEGIN' then
		begin
		Add(STBeginEnd.Create);
		LastChunk.GoRead;
		NI := 'END';
		end;
	until NI='END';
	end;
end;

procedure STProcedure.GoWrite(const FWriteClass:STWriteClass = nil);
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
if FPlace=STUHeader then
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


{===========}(*STVar*){===========}
procedure STVar.GoWrite(const FWriteClass:STWriteClass = nil);
var
	i:LongWord;
begin
for i:=0 to High(FVariables) do
	FWriteClass.WriteLn(FType+' '+FVariables[i]+' ;');
end;

class function STVar.ClassName:string;
begin
Result:='VAR';
end;

constructor STVar.Create;
begin
inherited;
FType:='';
FExpression:=nil;
FVariables:=nil;
end;

destructor STVar.Destroy;
begin
if (FVariables<>nil) and (Length(FVariables)<>0) then
	begin
	SetLength(FVariables,0);
	end;
if FExpression<>nil then
	FExpression.Destroy;
inherited;
end;

procedure STVar.GoRead;
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
	FExpression:=STExpression.Create;
	FExpression.FParent:=Self;
	FExpression.FReadClass:=FReadClass;
	FExpression.GoRead;
	
	FReadClass.NextIdentifier;
	end;

SourceToLog(['STVariable.GoRead : Succsesful Of Type "',FType,'"']);
end;

{===========}(*STComment*){===========}

procedure STComment.GoWrite(const FWriteClass:STWriteClass = nil);
begin
FWriteClass.Write('/*'+FComment+'*/');
end;

class function STComment.ClassName:string;
begin
Result:='COMMENT';
end;

constructor STComment.Create;
begin
inherited;
FComment:='';
end;

destructor STComment.Destroy;
begin
inherited;
end;

procedure STComment.GoRead;
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
//SourceToLog(['STComment.GoRead : I = "',i,'", FComment = "',FComment,'"']);
until i=0;
end;

{=============}(*STInfoChunk*){===========}

constructor STInfoChunk.Create(const Dir,Id:String);
begin
inherited Create;
FIdentity:=Id;
FDirictive:=Dir;
end;

{==================}(*STInfo*){================}

procedure STInfo.DeleteIf;
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

procedure STInfo.Add(const NewInfo:STInfoChunk);
begin
if FInfo=nil then
	SetLength(FInfo,1)
else
	SetLength(FInfo,Length(FInfo)+1);
FInfo[High(FInfo)]:=NewInfo;
end;

function STInfo.Defined(const Id:String):Boolean;
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

function STInfo.Mode:String;
var
	i:LongWord;
begin
Result:='FPC';
if FInfo<>nil then
	for i:=0 to High(FInfo) do
		if FInfo[i].FDirictive = 'MODE' then
			Result:=FInfo[i].FIdentity;
end;

function STInfo.AsmMode:String;
var
	i:LongWord;
begin
Result:='INTEL';
if FInfo<>nil then
	for i:=0 to High(FInfo) do
		if FInfo[i].FDirictive = 'ASMMODE' then
			Result:=FInfo[i].FIdentity;
end;

function STInfo.H:Boolean;
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

constructor STInfo.Create;
begin
inherited;
FInfo:=nil;
end;

destructor STInfo.Destroy;
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

{=======}(*STBeginEnd*){=============}
{$NOTE STBeginEnd}

procedure STBeginEnd.GoRead;
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

procedure STBeginEnd.GoWrite(const FWriteClass:STWriteClass = nil);
var
	i:LongWord;
begin
if FParent is STProgram then
	begin
	FWriteClass.WriteLn(' {');
	end;
if FChunks<>nil then
	for i:=0 to High(FChunks) do
		if FChunks[i]<>nil then
			FChunks[i].GoWrite(FWriteClass);
if FParent is STProgram then
	begin
	FWriteClass.WriteLn('return 0 ;');
	FWriteClass.WriteLn('}');
	end;
end;

class function STBeginEnd.ClassName:string;inline;
begin
Result:='BEGIN END';
end;

constructor STBeginEnd.Create;
begin
inherited;
end;

destructor STBeginEnd.Destroy;
begin
inherited;
end;

{===============}(*STProgram*){===============}

class function STProgram.ClassName:string;inline;
begin
Result:='PROGRAM';
end;

constructor STProgram.Create;
begin
inherited;
end;

destructor STProgram.Destroy;
begin
inherited;
end;
{$NOTE STProgram}
procedure STProgram.GoRead;
var
	NI:String = '';
begin
repeat
NI:=FReadClass.NextIdentifier;
SourceToLog(['STProgram.GoRead : NextId = "',NI,'"']);
if NI='PROGRAM' then
	begin
	FName:=FReadClass.NextIdentifier;
	SourceToLog(['TSTProgram.GoRead : Read Name Program "',FName,'"']);
	if FReadClass.NextIdentifier <> ';' then
		begin
		SourceToLog(['TSTProgram.GoRead : After Name Must Be ";"']);
		end;
	end
else if (NI='PROCEDURE') then
	begin
	Add(STProcedure.Create);
	FChunks[High(FChunks)].GoRead;
	end
else if (NI='VAR') then
	begin
	repeat
	Add(STVar.Create);
	LastChunk.GoRead;
	until NextIdentifierIsZS or (NextIdentifierMRM='(*') or (NextIdentifierMRM='{'); 
	end
else if (NI='CONST') then
	begin
	repeat
	Add(STConst.Create);
	LastChunk.GoRead;
	until NextIdentifierIsZS; 
	end
else if NI='USES' then
	begin
	repeat
	NI:=FReadClass.NextIdentifier;
	(FParent as TSTranslater).GoFindAndReadUnit(NI);
	Add(STModule.Create);
	LastChunk.FName:=NI;
	NI:=FReadClass.NextIdentifier;
	until NI=';';
	end
else if NI='BEGIN' then
	begin 
	Add(STBeginEnd.Create);
	FChunks[High(FChunks)].GoRead;
	NI:='.';
	end
else if NI='{' then
	begin
	Add(STComment.Create);
	FChunks[High(FChunks)].GoRead;
	end;
until (NI='.') or (NI='END');
end;

procedure STProgram.GoWrite(const FWriteClass:STWriteClass = nil);
var
	FStream:STWriteClass = nil;
	i:LongWord;
begin
SourceToLog(['STProgram.GoWrite : Beginning']);
FStream:=STWriteClass.Create(OutWay+FWay+FName+'.cpp');
FStream.WriteLn('//'+FName+'.pas');
FStream.Writeln('#include "SmoothHeader.h"');
if FChunks<>nil then
	for i:=0 to High(FChunks) do
		begin
		if FChunks[i] is STBeginEnd then
			begin
			FStream.Write('int main ( int argc, char * argv [] )')
			end;
		FChunks[i].GoWrite(FStream);
		if not (((i<High(FChunks)) and (FChunks[i] is STModule) and (FChunks[i+1] is STModule))) then
			FStream.WriteLn('');
		end;
FStream.Destroy;
end;

{=========}(*STUnit*){=========}
class function STUnit.ClassName:string;inline;
begin
Result:='UNIT';
end;

constructor STUnit.Create;
begin
inherited;
FPlace:=STUHeader;
end;

destructor STUnit.Destroy;
begin
inherited;
end;

{$NOTE STUnit}
procedure STUnit.GoRead;
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
	FPlace := STUHeader;
	end
else if (NI='PROCEDURE') then
	begin
	Add(STProcedure.Create);
	FChunks[High(FChunks)].FPlace:=FPlace;
	FChunks[High(FChunks)].GoRead;
	end
else if (NI='VAR') then
	begin
	repeat
	Add(STVar.Create);
	LastChunk.FPlace:=FPlace;
	LastChunk.GoRead;
	until NextIdentifierIsZS; 
	end
else if (NI='CONST') then
	begin
	repeat
	Add(STConst.Create);
	LastChunk.FPlace:=FPlace;
	LastChunk.GoRead;
	until NextIdentifierIsZS; 
	end
else if NI='USES' then
	begin
	repeat
	NI:=FReadClass.NextIdentifier;
	(FParent as TSTranslater).GoFindAndReadUnit(NI);
	Add(STModule.Create);
	LastChunk.FName:=NI;
	LastChunk.FPlace:=FPlace;
	NI:=FReadClass.NextIdentifier;
	until NI=';';
	end
else if NI = 'IMPLEMENTATION' then
	begin
	FPlace:=STUCPP;
	end
else if NI = 'END' then
	ToExit:=True;
until ToExit;
FPlace:=STUUnsigned;
end;

procedure STUnit.GoWrite(const FWriteClass:STWriteClass = nil);
var
	FStream:STWriteClass = nil;
	i:LongWord;
begin

FStream:=STWriteClass.Create(OutWay+FWay+FName+'.h');
FStream.WriteLn('//Header (Interface) of "'+FName+'.pas"');
FStream.WriteLn('#ifndef '+FName+'_included');
FStream.WriteLn('#define '+FName+'_included');
FStream.Writeln('#include "SmoothHeader.h"');
if FChunks<>nil then
	for i:=0 to High(FChunks) do
		if FChunks[i].FPlace=STUHeader then
			begin
			FChunks[i].GoWrite(FStream);
			FStream.WriteLn('');
			end;
FStream.WriteLn('#endif');
FStream.Destroy;

FStream:=STWriteClass.Create(OutWay+FWay+FName+'.cpp');
FStream.WriteLn('//CPP (Implementation) of "'+FName+'.pas"');
FStream.WriteLn('#include "'+FName+'.h"');
if FChunks<>nil then
	for i:=0 to High(FChunks) do
		if FChunks[i].FPlace=STUCPP then
			begin
			FChunks[i].GoWrite(FStream);
			FStream.WriteLn('');
			end;
FStream.Destroy;
end;

{=============}(*STReadClassComponent*){===========}

procedure STReadClassComponent.SourceToLog(const Ar:packed array of const);
var
	OutString:String;
	I:LongWord;
begin
OutString:='';
OutString:=SStr(Ar);
SLog.Source(['[ ',FReadClass.StringInfo,' ] ',OutString]);
SetLength(OutString,0);
end;

function STReadClassComponent.NextIdentifierMRM:string;
begin
FReadClass.Member;
Result:=FReadClass.NextIdentifier;
FReadClass.ReMember;
end;


class function STReadClassComponent.ClassName:string;inline;
begin
Result:='READ CLASS COMPONENT';
end;

constructor STReadClassComponent.Create;
begin
inherited;
FReadClass:=nil;
end;

destructor STReadClassComponent.Destroy;
begin
if FReadClass<>nil then
	if (FParent is STReadClassComponent) and ((FParent as STReadClassComponent).FReadClass=FReadClass) then else 
		FReadClass.Destroy;
inherited;
end;

function STReadClassComponent.NextIdentifierIsZS:Boolean;
begin
FReadClass.Member;
Result:= IsZS([
	'TYPE',  'LABEL',  'INTERFACE','IMPLEMENTATION','BEGIN'    ,'END'  ,'VAR',
	'PUBLIC','PRIVATE','PUBLISHED','FUNCTION'      ,'PROCEDURE','CLASS',
	'DESTRUCTOR','CONSTRUCTOR','PROPERTY','CONST','FOR','DO','THEN','ELSE','IF','TO','DOWNTO'],FReadClass.NextIdentifier);
FReadClass.ReMember;
end;
{==========}(*STComponent*){==========}

function STComponent.GetOutWay:string;
begin
if FParent<>nil then
	Result:=FParent.OutWay
else
	Result:='';
end;

function STComponent.LastChunk:STComponent;inline;
begin
if (FChunks=nil) or (Length(FChunks)=0) then
	Result:=nil
else
	Result:=FChunks[High(FChunks)];
end;

function STComponent.TransliatorClass:STranslater;
begin
if Self is  STranslater then
	Result:=(Self as STranslater)
else
	if FParent is STranslater then
		Result:=(FParent as STranslater)
	else
		Result:=FParent.TransliatorClass;
end;

function STComponent.IsZS(const Ar:array of const;const Sl:String):Boolean;
var
	i:LongWord;
begin
Result:=False;
if High(Ar)>=0 then 
	begin
	for i := 0 to High(ar) do
		case ar[i].vtype of
		vtString: 
			if SUpCaseString(ar[i].vstring^) = SUpCaseString(Sl) then
				begin
				Result:=True;
				Exit;
				end;
		vtAnsiString: 
			begin
			if SUpCaseString((AnsiString(ar[i].vpointer))) = SUpCaseString(Sl) then
				begin
				Result:=True;
				Exit;
				end;
			end;
		end;
	end;
end;

procedure STComponent.Add(const NewComponent:STComponent);
begin
if (FChunks=nil) then
	SetLength(FChunks,1)
else
	SetLength(FChunks,Length(FChunks)+1);
FChunks[High(FChunks)]:=NewComponent;
FChunks[High(FChunks)].FParent:=Self;
if (Self is STReadClassComponent) and (NewComponent is STReadClassComponent) then
	(NewComponent as STReadClassComponent).FReadClass:=(Self as STReadClassComponent).FReadClass;
end;

class function STComponent.ClassName:string;inline;
begin
Result:='COMPONENT';
end;

constructor STComponent.Create;
begin
inherited;
FPlace:=STUUnsigned;
FParent:=nil;
FName:='';
end;

destructor STComponent.Destroy;
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

procedure STComponent.GoRead;
begin
end;

procedure STComponent.GoWrite(const FWriteClass:STWriteClass = nil);
begin
end;

{==========}(*STranslater*){==========}

function TSTranslater.GetOutWay:string;
begin
Result:=FOutWay;
end;

procedure TSTranslater.GoWrite(const FWriteClass:STWriteClass = nil);
var 
	i:LongWord;
	FSH:STWriteClass = nil;
begin
SMakeDirectories(FOutWay);

FSH:=STWriteClass.Create(FOutWay + 'SmoothHeader.h');
FSH.WriteLn('#ifndef sageheader_included');
FSH.WriteLn('#define sageheader_included');
FSH.WriteLn('#include <iostream>');
FSH.WriteLn('#include <cstring>');
FSH.WriteLn('using namespace std;');
FSH.WriteLn('typedef signed long int LONGINT ;');
FSH.WriteLn('typedef signed int INTEGER ;');
FSH.WriteLn('typedef float SINGLE ;');
FSH.WriteLn('typedef double REAL ;');
FSH.WriteLn('typedef unsigned short BYTE ;');
FSH.WriteLn('typedef signed short SHORTINT ;');
FSH.WriteLn('typedef signed long long int INT64 ;');
FSH.WriteLn('typedef unsigned char CHAR ;');
FSH.WriteLn('typedef const char* STRING ;');
FSH.WriteLn('typedef bool BOOLEAN ;');
FSH.WriteLn('typedef const bool LONGBOOL ;');
FSH.WriteLn('#define true TRUE');
FSH.WriteLn('#define false FALSE');
FSH.WriteLn('#endif');
FSH.Destroy;

if FChunks<>nil then
for i:=0 to High(FChunks) do
	begin
	if (FChunks[i]<>nil) then
		begin
		FChunks[i].GoWrite{(FWriteClass)};
		end;
	end;
end;

function TSTranslater.GoFindAndReadUnit(const VWay:string):Boolean;

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
SLog.Source(['TSTranslater.GoFindAndReadUnit : Create Unit Chunck "',Way,'"']);
SetLength(FChunks,Length(FChunks)+1);
FChunks[High(FChunks)]:=STUnit.Create;
FChunks[High(FChunks)].FName:=Way;
(FChunks[High(FChunks)] as STReadClassComponent).FReadClass:=STReadClass.Create(STRead.Create(Way+'.pas'));
FChunks[High(FChunks)].FParent:=Self;
SLog.Source(['TSTranslater.GoRead : Go Read "',Length(FChunks),'" Chunck "',Way,'"']);
FChunks[High(FChunks)].GoRead;
Result:=True;
end;

function TSTranslater.FileType(const VWay:string):string;
var
	RC:STReadClass = nil;
begin
RC:=STReadClass.Create;
RC.Add(STRead.Create(VWay));
Result:=SUpCaseString(RC.NextIdentifier);
RC.Destroy;
if (Result='VAR') or (Result='USES') or 
	(Result='TYPE') or (Result='BEGIN') or(Result='LABEL') or
	(Result='PROCEDURE') or (Result='FUNCTION') then
		Result:='PROGRAM';
if (Result<>'PROGRAM') and
	(Result<>'UNIT') and 
	(Result<>SUpCaseString('library')) then
		Result:='';
end;

procedure TSTranslater.GoRead;
var
	FT:String = '';
	I,ii:LongWord;
var
	MW:String = '';
	WasInCmd:Boolean = False;
var
	AnyError : TSBool = False;
begin
if SUpCaseString(FObject)='CMD' then
	begin
	SLog.Source(['TSTranslater.GoRead : Start Reading (Cmd Type)']);
	if (FParams <> nil) and (Length(FParams) > 0) then
	for ii:=0 to High(FParams) do
		begin
		FT:=SUpCaseString(FParams[ii]);
		if (FT[1]<>'-') then
			begin
			AnyError := True;
			Writeln('Befor command "',FT,'" must be "-".');
			SLog.Source(['TSTranslater.GoRead : ','Befor command "',FT,'" must be "-".']);
			end
		else if Length(FT)<3 then
			begin
			AnyError := True;
			Writeln('Error syntax command "',FT,'". (Length>3)');
			SLog.Source(['TSTranslater.GoRead : ','Error syntax command "',FT,'" (Length>3).']);
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
				if not (FOutWay[Length(FOutWay)] in [UnixDirectorySeparator, WinDirectorySeparator]) then
					FOutWay += DirectorySeparator;
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
				SLog.Source(['TSTranslater.GoRead : ','Error syntax command "',FT,'".']);
				end;
			end;
		end;
	WasInCmd:=True;
	end;
if AnyError then
	begin
	SHint(['Help:']);
	SHint(['  Use -pm(%path_makefile) for set makefile path.']);
	SHint(['  Use -ow(%out_path) for set out path.']);
	SHint(['  Use -pp(%object_path) for set object path to translate.']);
	SHint(['  Use -pu(%object_path) for set object path to translate.']);
	SHint(['  Use -pl(%object_path) for set object path to translate.']);
	Halt(0);
	end;
if (SFileExtension(SUpCaseString(FObject))='PAS') or (SFileExtension(SUpCaseString(FObject))='PP') then
	begin
	SLog.Source(['TSTranslater.GoRead : Start Reading (Not Makefile Type)']);
	FT:=FileType(FObject);
	if FT='' then
		begin
		AnyError := True;
		SLog.Source(['TSTranslater.GoRead : Error Getting File Type "',FObject,'"']);
		end
	else
		begin
		SLog.Source(['TSTranslater.GoRead : Create Chunck "',FT,'"']);
		SetLength(FChunks,1);
		if FT='PROGRAM' then
			FChunks[0]:=STProgram.Create;
		if FT='UNIT' then
			FChunks[0]:=STUnit.Create;
		if FT=SUpCaseString('library') then
			;//FChunks[0]:=STUnit.Create;
		(FChunks[0] as STReadClassComponent).FReadClass:=STReadClass.Create(STRead.Create(FObject));
		FChunks[0].FParent:=Self;
		SLog.Source(['TSTranslater.GoRead : Go Read First Chunck "',FT,'"']);
		FChunks[0].GoRead;
		end;
	end
else  if (not WasInCmd) or (WasInCmd and (MW='')) then
	begin
	AnyError := True;
	SLog.Source(['TSTranslater.GoRead : Don''t know what a you doing!']);
	if WasInCmd then
		WriteLn('TSTranslater.GoRead : Don''t know what a you doing!');
	end
else {= Makefile}
	begin
	if WasInCmd then
		FObject:=MW;
	SLog.Source(['TSTranslater.GoRead : Start Reading (Makefile Type)']);
	if (SFileName(FObject)='') and (SFileExtension(FObject)='') then
		begin
		FObject+='Makefile';
		end;
	if SFileExists(FObject) then
		begin
		SLog.Source(['TSTranslater.GoRead : Finded makefile.']);
		end
	else
		begin
		SLog.Source(['TSTranslater.GoRead : Don''t find makefile.']);
		if WasInCmd then
			WriteLn('Don''t find makefile..');
		end;
	end;
end;

class function STranslater.Create(const VWay:String):STranslater;overload;
begin
Result:=STranslater.Create;
Result.FObject:=VWay;
end;

procedure STranslater.GoTranslate;inline;
begin
GoRead;
GoWrite;
end;

class function STranslater.ClassName:string;inline;
begin
Result:='TRANSLATER';
end;

constructor STranslater.Create;
begin
inherited;
FWays:=nil;
FChunks:=nil;
FOutWay:='';
end;

destructor STranslater.Destroy;
begin
inherited;
end;

{=====}(*STRead*){=====}

function STRead.StringInfo:String;
begin
Result:='"'+FWay+'":'+SStr(FLine)+'x'+SStr(FColumn)+'';
end;

procedure STRead.Member;
begin
if (FMember<>nil) then
	SetLength(FMember,Length(FMember)+1)
else
	SetLength(FMember,1);
FMember[High(FMember)].FPosition:=FStream.Position;
FMember[High(FMember)].FLine:=FLine;
FMember[High(FMember)].FColumn:=FColumn;
end;

procedure STRead.ReMember;
begin
if (FStream<>nil) and (FMember<>nil) and (Length(FMember)>=1) then
	begin
	FStream.Position:=FMember[High(FMember)].FPosition;
	FLine:=FMember[High(FMember)].FLine;
	FColumn:=FMember[High(FMember)].FColumn;
	SetLength(FMember,Length(FMember)-1);
	end;
end;

function STRead.ReadChar:Char;
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
	SLog.Source('STRead.ReadChar : Stream.Position = Stream.Size');
end;

class function STRead.Create(const Way:String):STRead;overload;
begin
Result:=STRead.Create;
Result.FWay:=Way;
end;

constructor STRead.Create;overload;
begin
inherited;
FWay:='';
FStream:=nil;
end;

destructor STRead.Destroy;
begin
if FStream<>nil then
	begin
	FStream.Destroy;
	FStream:=nil;
	end;
inherited;
end;

function STRead.NextIdentifier:string;
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
Result:=SUpCaseString(ReadCircle());
//SourceToLog(['Translator : Low  Identity of "',FWay,'" is "',Result,'"']);
end;

procedure STRead.MovePos(const I:Int64);
begin
FStream.Position:=FStream.Position+I;
end;

function STRead.ReadCircle:string;
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

{=============}(*TSTReadClass*){=============}

function TSTReadClass.StringInfo:String;
begin
if (FFiles=nil) or (Length(FFiles)=0) then
	Result:=''
else
	Result:=FFiles[High(FFiles)].StringInfo;
end;

procedure TSTReadClass.UnReadComments;
var
	Quantity:LongWord = 1;
	C:Char = #0;
begin
SLog.Source(['TSTReadClass.UnReadComments']);
while Quantity>0 do
	begin
	C:=FFiles[High(FFiles)].ReadChar;
	if C='{' then
		Quantity+=1
	else if C='}' then
		Quantity-=1;
	end;
end;

function TSTReadClass.ReadChar:Char;
begin
Result:=FFiles[High(FFiles)].ReadChar;
end;

function TSTReadClass.NextIdentifier:String;
var
	Id1:String;
	Id2:String;

procedure Obhod;
var
	ii:LongWord;
	Identity3:String;
begin
SLog.Source('TSTReadClass.NextIdentifier.Obhod');
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
FFiles[High(FFiles)]:=STRead.Create(Way);
end;

begin
Result:='';
if (FFiles=nil) or (Length(FFiles)=0) then
	SLog.Source('TSTReadClass.NextIdentifier : Quantity Files = 0')
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
				FInfo.Add(STInfoChunk.Create('IF',''));
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
				FInfo.Add(STInfoChunk.Create('DEFINE',Id2));
				UnReadComments;
				end
			else if Id1='MODE' then
				begin
				Id2:=FFiles[High(FFiles)].NextIdentifier;
				FInfo.Add(STInfoChunk.Create('MODE',Id2));
				UnReadComments;
				end
			else if Id1='UNDEF' then
				begin
				Id2:=FFiles[High(FFiles)].NextIdentifier;
				FInfo.Add(STInfoChunk.Create('UNDEF',Id2));
				UnReadComments;
				end
			else if Id1='ASMMODE' then
				begin
				Id2:=FFiles[High(FFiles)].NextIdentifier;
				FInfo.Add(STInfoChunk.Create('ASMMODE',Id2));
				UnReadComments;
				end
			else if Id1='H' then
				begin
				Id2:=FFiles[High(FFiles)].NextIdentifier;
				FInfo.Add(STInfoChunk.Create('H',Id2));
				UnReadComments;
				end
			else
				UnReadComments;
			Result:=Self.NextIdentifier();
			end;
	end;
//SourceToLog(['Translator : High Identity of "',FFiles[High(FFiles)].FWay,'" is "',Result,'"']);
end;

class function TSTReadClass.Create(const TRead:STRead):STReadClass;overload;
begin
Result:=TSTReadClass.Create;
Result.Add(TRead);
end;

procedure TSTReadClass.Add(const TRead:STRead);
begin
if FFiles=nil then
	SetLength(FFiles,1)
else
	SetLength(FFiles,Length(FFiles)+1);
FFiles[High(FFiles)]:=TRead;
end;

destructor TSTReadClass.Destroy;
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

procedure TSTReadClass.Member;
begin
if (FFiles<>nil) and (Length(FFiles)>0) then
	FFiles[High(FFiles)].Member;
end;

procedure TSTReadClass.ReMember;
begin
if (FFiles<>nil) and (Length(FFiles)>0) then
	FFiles[High(FFiles)].ReMember;
end;

constructor TSTReadClass.Create;
begin
inherited;
FFiles:=nil;
FInfo:=STInfo.Create;
FWithComments:=True;
FWithDirictives:=True;
end;

end.
