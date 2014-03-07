{$INCLUDE Includes\SaGe.inc}

unit SaGeResourseManager;

interface

uses 
	 SaGeBase
	 ,SaGeBased
	 ,Classes
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

implementation

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
end;

finalization
begin
SGResourseManager.Destroy();
end;

end.
