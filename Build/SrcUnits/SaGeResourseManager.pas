{$INCLUDE Includes\SaGe.inc}
unit SaGeResourseManager;

interface

uses 
	 SaGeBase
	 ,SaGeBased
	 ,Classes
	 ,Crt
	 ,SysUtils;
type
	TSGResourse=class(TSGClass)
		end;
type
	TSGResourseManipulatorExpansions = packed array of
		packed record
			RExpansion : TSGString;
			RLoadIsSupported : TSGBoolean;
			RSaveIsSupported : TSGBoolean;
			end;
type
	TSGResourseManipulator = class;
	TSGResourseManipulatorClass = class of TSGResourseManipulator;
	TSGResourseManipulator = class(TSGClass)
			public
		constructor Create();override;
		destructor Destroy();override;
			private
		FQuantityExpansions : TSGLongWord;
		FArExpansions : TSGResourseManipulatorExpansions;
			protected
		procedure AddExpansion(const VExpansion:TSGString;const VLoadIsSupported, VSaveIsSupported : TSGBoolean);
			public
		function LoadingIsSuppored(const VExpansion : TSGString):TSGBoolean;
		function SaveingIsSuppored(const VExpansion : TSGString):TSGBoolean;
		function LoadResourse(const VFileName,VExpansion : TSGString):TSGResourse;
		function SaveResourse(const VFileName,VExpansion : TSGString;const VResourse : TSGResourse):TSGBoolean;
		function LoadResourseFromStream(const VStream : TStream;const VExpansion : TSGString):TSGResourse;virtual;
		function SaveResourseToStream(const VStream : TStream;const VExpansion : TSGString;const VResourse : TSGResourse):TSGBoolean;virtual;
		end;
type
	TSGResourseManager = class(TSGClass)
			public
		constructor Create();override;
		destructor Destroy();override;
			private
		FQuantityManipulators : TSGLongWord;
		FArManipulators : packed array of TSGResourseManipulator;
			public
		procedure AddManipulator(const VManipulatorClass : TSGResourseManipulatorClass);
		function LoadingIsSuppored(const VExpansion : TSGString):TSGBoolean;
		function SaveingIsSuppored(const VExpansion : TSGString):TSGBoolean;
		function LoadResourse(const VFileName,VExpansion : TSGString):TSGResourse;
		function SaveResourse(const VFileName,VExpansion : TSGString;const VResourse : TSGResourse):TSGBoolean;
		function LoadResourseFromStream(const VStream : TStream;const VExpansion : TSGString):TSGResourse;
		function SaveResourseToStream(const VStream : TStream;const VExpansion : TSGString;const VResourse : TSGResourse):TSGBoolean;
		end;
var
	SGResourseManager : TSGResourseManager = nil;
type
	TSGResourseFilesProcedure = procedure (const Stream:TStream);
	TSGResourseFiles = class(TSGClass)
			public
		constructor Create();
		destructor Destroy();override;
			public
		procedure AddFile(const FileWay:TSGString;const Proc : TSGPointer);
		function LoadMemoryStreamFromFile(const Stream:TMemoryStream;const FileName:TSGString):TSGBoolean;
		function ExistsInFile(const Name:TSGString):TSGBoolean;
		function WaysEqual(w1,w2:TSGString):TSGBoolean;
		function FileExists(const FileName : TSGString):TSGBoolean;inline;
			private
		FArFiles:packed array of
			packed record
				FWay:TSGString;
				FSelf:TSGResourseFilesProcedure;
				end;
		end;
var
	SGResourseFiles:TSGResourseFiles = nil;


const
	SGConvertFileToPascalUnitDefInc = True;
//Это тупая и очень тупая процедура, сделал ее специально для андроида.
(*Скорее всего она не найдет свое применение, но для начала не помешает*)
//В общем ты ей задаешь файл, а она тебе пишет модуль на паскале
//И при вызове особой процедурки из этого модуля при включении 
//Этого модуля в программу у тебя конструируется TMemoryStream,
//В котором и будет тот файл, который ты задал в FileName
procedure SGConvertFileToPascalUnit(const FileName,UnitWay,NameUnit:TSGString;const IsInc:TSGBoolean = SGConvertFileToPascalUnitDefInc);
procedure SGRegisterUnit(const UnitName,RFFile:TSGString);
procedure SGClearRFFile(const RFFile:TSGString);

implementation

procedure SGClearRFFile(const RFFile:TSGString);
var
	Stream:TFileStream = nil;
begin
Stream:=TFileStream.Create(RFFile,fmCreate);
SGWriteStringToStream('(*This patr from SaGe*)'+SGWinEoln,Stream,False);
SGWriteStringToStream('//RF file. Files:'+SGWinEoln,Stream,False);
Stream.Destroy();
end;

procedure SGRegisterUnit(const UnitName,RFFile:TSGString);
var
	Stream:TFileStream = nil;
	MemStream:TMemoryStream = nil;
begin
MemStream:=TMemoryStream.Create();
MemStream.LoadFromFile(RFFile);
Stream:=TFileStream.Create(RFFile,fmCreate);
MemStream.Position:=0;
MemStream.SaveToStream(Stream);
MemStream.Destroy();
SGWriteStringToStream('	,'+UnitName+SGWinEoln,Stream,False);
Stream.Destroy();
end;

procedure SGConvertFileToPascalUnit(const FileName,UnitWay,NameUnit:TSGString;const IsInc:TSGBoolean = SGConvertFileToPascalUnitDefInc);
var
	Step:LongWord = 1000000;
var
	OutStream:TStream = nil;
	InStream:TStream = nil;
	A:array of Byte;
	I,iiii,i5:LongWord;
procedure WriteProc(const ThisStep:LongWord);
var
	III,II:LongWord;
begin
InStream.ReadBuffer(A[0],ThisStep);
SGWriteStringToStream('procedure '+'LoadToStream_'+NameUnit+'_'+SGStr(I)+'(const Stream:TStream);'+SGWinEoln,OutStream,False);
I+=1;
SGWriteStringToStream('var'+SGWinEoln,OutStream,False);
SGWriteStringToStream('	A:array ['+'1..'+SGStr(ThisStep)+'] of byte = ('+SGWinEoln+'	',OutStream,False);
II:=0;
for iii:=0 to ThisStep-1 do
	begin
	if II=10 then
		begin
		SGWriteStringToStream(''+SGWinEoln+'	',OutStream,False);
		II:=0;
		end;
	SGWriteStringToStream(SGStr(A[iIi]),OutStream,False);
	if III<>ThisStep-1 then
		SGWriteStringToStream(', ',OutStream,False);
	II+=1;
	end;
SGWriteStringToStream(');'+SGWinEoln,OutStream,False);
SGWriteStringToStream('begin'+SGWinEoln,OutStream,False);
SGWriteStringToStream('Stream.WriteBuffer(A,'+SGStr(ThisStep)+');'+SGWinEoln,OutStream,False);
SGWriteStringToStream('end;'+SGWinEoln,OutStream,False);
end;
begin
I:=0;
SetLength(A,Step);
OutStream:=TFileStream.Create(UnitWay+Slash+NameUnit+'.pas',fmCreate);
InStream:=TFileStream.Create(FileName,fmOpenRead);
if IsInc then
	SGWriteStringToStream('{$INCLUDE SaGe.inc}'+SGWinEoln,OutStream,False)
else
	SGWriteStringToStream('{$MODE OBJFPC}'+SGWinEoln,OutStream,False);
SGWriteStringToStream('//"'+FileName+'"'+SGWinEoln,OutStream,False);
SGWriteStringToStream('unit '+NameUnit+';'+SGWinEoln,OutStream,False);
SGWriteStringToStream('interface'+SGWinEoln,OutStream,False);
if IsInc then
	SGWriteStringToStream('implementation'+SGWinEoln,OutStream,False);
SGWriteStringToStream('uses'+SGWinEoln,OutStream,False);
if IsInc then
	SGWriteStringToStream('	SaGeResourseManager,'+SGWinEoln,OutStream,False);
SGWriteStringToStream('	Classes;'+SGWinEoln,OutStream,False);
if not IsInc then
	begin
	SGWriteStringToStream('procedure LoadToStream_'+NameUnit+'(const Stream:TStream);'+SGWinEoln,OutStream,False);
	SGWriteStringToStream('implementation'+SGWinEoln,OutStream,False);
	end;
while InStream.Position<=InStream.Size-Step do
	WriteProc(Step);
if InStream.Position<>InStream.Size then
	begin
	IIii:=InStream.Size-InStream.Position;
	WriteProc(IIii);
	end;
SGWriteStringToStream('procedure LoadToStream_'+NameUnit+'(const Stream:TStream);'+SGWinEoln,OutStream,False);
SGWriteStringToStream('begin'+SGWinEoln,OutStream,False);
for i5:=0 to i-1 do
	SGWriteStringToStream('LoadToStream_'+NameUnit+'_'+SGStr(i5)+'(Stream);'+SGWinEoln,OutStream,False);
SGWriteStringToStream('end;'+SGWinEoln,OutStream,False);
if IsInc then
	begin
	SGWriteStringToStream('initialization'+SGWinEoln,OutStream,False);
	SGWriteStringToStream('begin'+SGWinEoln,OutStream,False);
	SGWriteStringToStream('SGResourseFiles.AddFile('''+FileName+''',@LoadToStream_'+NameUnit+');'+SGWinEoln,OutStream,False);
	SGWriteStringToStream('end;'+SGWinEoln,OutStream,False);
	end;
SGWriteStringToStream('end.'+SGWinEoln,OutStream,False);
SetLength(A,0);
Write('Converted');
TextColor(14);
Write('"',SGGetFileName(FileName)+'.'+SGDownCaseString(SGGetFileExpansion(FileName)),'"');
TextColor(7);
Write(':in:');
TextColor(10);
Write(SGGetSizeString(InStream.Size,'EN'));
TextColor(7);
Write(',out:');
TextColor(12);
Write(SGGetSizeString(OutStream.Size,'EN'));
TextColor(7);
WriteLn('.');
InStream.Destroy();
OutStream.Destroy();
end;

(*===========TSGResourseFiles===========*)

function TSGResourseFiles.WaysEqual(w1,w2:TSGString):TSGBoolean;
var
	i:TSGMaxEnum;
function SimbolsEqual(const s1,s2:TSGChar):TSGBoolean;
begin
if ((s1=UnixSlash) or (s1=WinSlash)) and ((s2=UnixSlash) or (s2=WinSlash)) then
	Result:=True
else
	Result:=s1=s2;
end;
begin
if Length(w1)=Length(w2) then
	begin
	w1:=SGUpCaseString(w1);
	w2:=SGUpCaseString(w2);
	Result:=True;
	for i:=1 to Length(w1) do
		if not SimbolsEqual(w1[i],w2[i]) then
			begin
			Result:=False;
			Break;
			end;
	end
else
	Result:=False;
end;

function TSGResourseFiles.FileExists(const FileName : TSGString):TSGBoolean;inline;
begin
Result:=ExistsInFile(FileName) or SGFileExists(FileName);
end;

function TSGResourseFiles.ExistsInFile(const Name:TSGString):TSGBoolean;
var
	i:TSGMaxEnum;
begin
Result:=False;
if FArFiles=nil then
	Exit;
for i:=0 to High(FArFiles) do
	begin
	if WaysEqual(FArFiles[i].FWay,Name) then
		begin
		Result:=True;
		Break;
		end;
	end;
end;

function TSGResourseFiles.LoadMemoryStreamFromFile(const Stream:TMemoryStream;const FileName:TSGString):TSGBoolean;
var
	i : TSGMaxEnum;
begin
Result:=False;
if Stream=nil then
	Exit;
if ExistsInFile(FileName) then
	begin
	for i:=0 to High(FArFiles) do
		if WaysEqual(FileName,FArFiles[i].FWay) then
			begin
			FArFiles[i].FSelf(Stream);
			Break;
			end;
	Result:=True;
	end
else
	if SGFileExists(FileName) then
		begin
		Stream.LoadFromFile(FileName);
		Result:=True;
		end;
end;

constructor TSGResourseFiles.Create();
begin
inherited;
FArFiles:=nil;
end;

destructor TSGResourseFiles.Destroy();
begin
SetLength(FArFiles,0);
inherited;
end;

procedure TSGResourseFiles.AddFile(const FileWay:TSGString;const Proc : TSGPointer);
begin
if FArFiles=nil then
	SetLength(FArFiles,1)
else
	SetLength(FArFiles,Length(FArFiles)+1);
FArFiles[High(FArFiles)].FWay:=FileWay;
FArFiles[High(FArFiles)].FSelf:=TSGResourseFilesProcedure(Proc);
end;

(*===========TSGResourseManipulator===========*)

destructor TSGResourseManipulator.Destroy();
begin
SetLength(FArExpansions,0);
inherited;
end;

function TSGResourseManipulator.LoadResourseFromStream(const VStream : TStream;const VExpansion : TSGString):TSGResourse;
begin
Result:=nil;
end;

function TSGResourseManipulator.SaveResourseToStream(const VStream : TStream;const VExpansion : TSGString;const VResourse : TSGResourse):TSGBoolean;
begin
Result:=False;
end;

function TSGResourseManipulator.SaveResourse(const VFileName,VExpansion : TSGString;const VResourse : TSGResourse):TSGBoolean;
var
	Stream : TStream = nil;
begin
Result:=False;
Stream := TFileStream.Create(VFileName,fmCreate);
if Stream<>nil then
	begin
	Result:=SaveResourseToStream(Stream,VExpansion,VResourse);
	Stream.Destroy();
	if not Result then
		if SGFileExists(VFileName) then
			DeleteFile(VFileName);
	end;
end;

function TSGResourseManipulator.LoadResourse(const VFileName,VExpansion : TSGString):TSGResourse;
var
	Stream : TStream = nil;
begin
Result:=nil;
if SGFileExists(VFileName) then
	begin
	Stream := TFileStream.Create(VFileName,fmOpenRead);
	if Stream<>nil then
		begin
		Result:=LoadResourseFromStream(Stream,VExpansion);
		Stream.Destroy();
		end;
	end;
end;

constructor TSGResourseManipulator.Create();
begin
inherited;
FQuantityExpansions:=0;
FArExpansions :=  nil;
end;

procedure TSGResourseManipulator.AddExpansion(const VExpansion:TSGString;const VLoadIsSupported, VSaveIsSupported : TSGBoolean);
begin
FQuantityExpansions+=1;
SetLength(FArExpansions,FQuantityExpansions);
FArExpansions[FQuantityExpansions-1].RExpansion:=SGUpCaseString(VExpansion);
FArExpansions[FQuantityExpansions-1].RLoadIsSupported:=VLoadIsSupported;
FArExpansions[FQuantityExpansions-1].RSaveIsSupported:=VSaveIsSupported;
end;

function TSGResourseManipulator.SaveingIsSuppored(const VExpansion : TSGString):TSGBoolean;
var
	Index : TSGLongWord;
begin
Result:=False;
if FQuantityExpansions<>0 then
	for Index := 0 to FQuantityExpansions-1 do
		if (SGUpCaseString(VExpansion) = FArExpansions[Index].RExpansion) and (FArExpansions[Index].RSaveIsSupported) then
			begin
			Result:=True;
			Break;
			end;
end;

function TSGResourseManipulator.LoadingIsSuppored(const VExpansion : TSGString):TSGBoolean;
var
	Index : TSGLongWord;
begin
Result:=False;
if FQuantityExpansions<>0 then
	for Index := 0 to FQuantityExpansions-1 do
		if (SGUpCaseString(VExpansion) = FArExpansions[Index].RExpansion) and (FArExpansions[Index].RLoadIsSupported) then
			begin
			Result:=True;
			Break;
			end;
end;

(*===========TSGResourseManager===========*)

destructor TSGResourseManager.Destroy();
begin
SetLength(FArManipulators,0);
inherited;
end;

function TSGResourseManager.LoadResourse(const VFileName,VExpansion : TSGString):TSGResourse;
var
	Index : TSGLongWord;
begin
Result:=nil;
if FQuantityManipulators <>0 then
	for Index := 0 to FQuantityManipulators - 1 do
		if FArManipulators[Index].LoadingIsSuppored(VExpansion) then
			begin
			Result:=FArManipulators[Index].LoadResourse(VFileName,SGUpCaseString(VExpansion));
			if Result <> nil then
				Break;
			end;
end;

function TSGResourseManager.SaveResourse(const VFileName,VExpansion : TSGString;const VResourse : TSGResourse):TSGBoolean;
var
	Index : TSGLongWord;
begin
Result:=False;
if FQuantityManipulators <>0 then
	for Index := 0 to FQuantityManipulators - 1 do
		if FArManipulators[Index].SaveingIsSuppored(VExpansion) then
			begin
			Result:=FArManipulators[Index].SaveResourse(VFileName,SGUpCaseString(VExpansion),VResourse);
			if Result then
				Break;
			end;
end;

function TSGResourseManager.LoadResourseFromStream(const VStream : TStream;const VExpansion : TSGString):TSGResourse;
var
	Index : TSGLongWord;
	StreamPosition : TSGQuadWord;
begin
Result:=nil;
StreamPosition := VStream.Position;
if FQuantityManipulators <>0 then
	for Index := 0 to FQuantityManipulators - 1 do
		if FArManipulators[Index].LoadingIsSuppored(VExpansion) then
			begin
			Result:=FArManipulators[Index].LoadResourseFromStream(VStream,SGUpCaseString(VExpansion));
			if Result <> nil then
				Break
			else
				VStream.Position := StreamPosition;
			end;
end;

function TSGResourseManager.SaveResourseToStream(const VStream : TStream;const VExpansion : TSGString;const VResourse : TSGResourse):TSGBoolean;
var
	Index : TSGLongWord;
	StreamPosition : TSGQuadWord;
begin
Result:=False;
StreamPosition := VStream.Position;
if FQuantityManipulators<>0 then
	for Index := 0 to FQuantityManipulators - 1 do
		if FArManipulators[Index].SaveingIsSuppored(SGUpCaseString(VExpansion)) then
			begin
			Result:=FArManipulators[Index].SaveResourseToStream(VStream,SGUpCaseString(VExpansion),VResourse);
			if Result  then
				begin
				Break;
				end
			else
				begin
				VStream.Position := StreamPosition;
				VStream.Size := StreamPosition;
				end;
			end;
end;

procedure TSGResourseManager.AddManipulator(const VManipulatorClass : TSGResourseManipulatorClass);
begin
FQuantityManipulators+=1;
SetLength(FArManipulators,FQuantityManipulators);
FArManipulators[FQuantityManipulators-1]:=VManipulatorClass.Create();
end;

function TSGResourseManager.SaveingIsSuppored(const VExpansion : TSGString):TSGBoolean;
var
	Index : TSGLongWord;
begin
Result:=False;
for Index := 0 to FQuantityManipulators - 1 do
	if FArManipulators[Index].SaveingIsSuppored(VExpansion) then
		begin
		Result:=True;
		Break;
		end;
end;

function TSGResourseManager.LoadingIsSuppored(const VExpansion : TSGString):TSGBoolean;
var
	Index : TSGLongWord;
begin
Result:=False;
if FQuantityManipulators <> 0 then
	for Index := 0 to FQuantityManipulators - 1 do
		if FArManipulators[Index].LoadingIsSuppored(VExpansion) then
			begin
			Result:=True;
			Break;
			end;
end;


constructor TSGResourseManager.Create();
begin
inherited;
FArManipulators :=nil;
FQuantityManipulators:=0;
end;

(*=======variable realization=====*)

initialization
begin
SGResourseManager := TSGResourseManager.Create();
SGResourseFiles:=TSGResourseFiles.Create();
end;

finalization
begin
SGResourseManager.Destroy();
SGResourseFiles.Destroy();
end;

end.
