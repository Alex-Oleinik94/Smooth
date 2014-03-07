{$INCLUDE Includes\SaGe.inc}

unit SaGeResourseManager;

interface

uses 
	 SaGeBase
	 ,SaGeBased;
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
			private
		FQuantityExpansions : TSGLongWord;
		FArExpansions : TSGResourseManipulatorExpansions;
			protected
		procedure AddExpansion(const VExpansion:TSGString;const VLoadIsSupported, VSaveIsSupported : TSGBoolean);
			public
		function LoadingIsSuppored(const VExpansion : TSGString):TSGBoolean;
		function SaveingIsSuppored(const VExpansion : TSGString):TSGBoolean;
		function LoadResourse(const VFileName,VExpansion : TSGString):TSGResourse;virtual;
		function SaveResourse(const VFileName,VExpansion : TSGString;const VResourse : TSGResourse):TSGBoolean;virtual;
		end;
type
	TSGResourseManager = class(TSGClass)
			public
		constructor Create();override;
			private
		FQuantityManipulators : TSGLongWord;
		FArManipulators : packed array of TSGResourseManipulator;
			public
		procedure AddManipulator(const VManipulatorClass : TSGResourseManipulatorClass);
		function LoadingIsSuppored(const VExpansion : TSGString):TSGBoolean;
		function SaveingIsSuppored(const VExpansion : TSGString):TSGBoolean;
		end;
var
	SGResourseManager : TSGResourseManager = nil;

implementation

(*===========TSGResourseManipulator===========*)

function TSGResourseManipulator.SaveResourse(const VFileName,VExpansion : TSGString;const VResourse : TSGResourse):TSGBoolean;
begin
Result:=False;
end;

function TSGResourseManipulator.LoadResourse(const VFileName,VExpansion : TSGString):TSGResourse;
begin
Result:=nil;
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
FArExpansions[FQuantityExpansions-1].RExpansion:=VExpansion;
FArExpansions[FQuantityExpansions-1].RLoadIsSupported:=VLoadIsSupported;
FArExpansions[FQuantityExpansions-1].RSaveIsSupported:=VSaveIsSupported;
end;

function TSGResourseManipulator.SaveingIsSuppored(const VExpansion : TSGString):TSGBoolean;
var
	Index : TSGLongWord;
begin
Result:=False;
for Index := 0 to FQuantityExpansions-1 do
	if (VExpansion = FArExpansions[Index].RExpansion) and (FArExpansions[Index].RSaveIsSupported) then
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
	if (VExpansion = FArExpansions[Index].RExpansion) and (FArExpansions[Index].RLoadIsSupported) then
		begin
		Result:=True;
		Break;
		end;
end;

(*===========TSGResourseManager===========*)

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
