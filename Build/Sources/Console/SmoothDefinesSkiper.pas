{$INCLUDE Smooth.inc}

unit SmoothDefinesSkiper;

interface

uses
	 Classes
	,Crt
	,SysUtils
	
	,SmoothBase
	,SmoothBaseClasses
	;

type
	TSDefine = object
			private
		FName : TSString;
		FValue : TSString;
			public
		procedure Clear();
		procedure Import(const VName : TSString; const VValue : TSString = '');
			public
		property Name  : TSString read FName  write FName;
		property Value : TSString read FValue write FValue;
		end;

function SDefineCreate(const VName : TSString; const VValue : TSString = '') : TSDefine; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator =(const A, B : TSDefine) : TSBool; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$DEFINE INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST_HELPER := TSDefineListHelper}
{$DEFINE DATATYPE_LIST        := TSDefineList}
{$DEFINE DATATYPE             := TSDefine}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}
{$UNDEF INC_PLACE_INTERFACE}

type
	TSDefinesSkiper = class(TSNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
			protected
		FOutputFileName : TSString;
		FOutput : TStream;
		FGeneralInputFileName : TSString;
		FGeneralInputPath : TSString;
		FDefines : TSDefineList;
			protected
		procedure Define(const VName : TSString; const VValue : TSString = '');
		procedure Undef(const VName : TSString);
		function Defined(const VName : TSString) : TSBool;
		function Macro(const VName : TSString) : TSString;
			protected
		procedure SetInput (const VInputFile  : TSString);
		procedure SetOutput(const VOutputFile : TSString);
		procedure KillOutput();
			protected
		procedure ProcessInput(const VInputFile : TSString); overload;
		procedure ProcessInput(const Stream : TStream); overload;
		function ReadNextIdentifier(const Stream : TStream) : TSString;
			public
		procedure Run();
			public
		property Output : TSString write SetOutput;
		property Input  : TSString write SetInput;
		end;

procedure SDefinesSkiper(const VInputFile, VOutputFile : TSString);

implementation

uses
	 SmoothFileUtils
	;

function TSDefinesSkiper.ReadNextIdentifier(const Stream : TStream) : TSString;
begin

end;

procedure TSDefinesSkiper.ProcessInput(const Stream : TStream); overload;
begin
while Stream.Position <> Stream.Size do
	begin
	
	end;
end;

procedure TSDefinesSkiper.Define(const VName : TSString; const VValue : TSString = '');
begin
if Defined(VName) then
	Undef(VName);
FDefines += SDefineCreate(VName, VValue);
end;

procedure TSDefinesSkiper.Undef(const VName : TSString);
var
	i, ii : TSUInt32;
begin
if (FDefines <> nil) and (Length(FDefines) > 0) then
	begin
	ii := Length(FDefines);
	for i := 0 to High(FDefines) do
		if FDefines[i].Name = VName then
			begin
			ii := i;
			break;
			end;
	if ii <> Length(FDefines) then
		begin
		if ii <> High(FDefines) then
			for i := ii to High(FDefines) - 1 do
				FDefines[i] := FDefines[i + 1];
		SetLength(FDefines, Length(FDefines) - 1);
		end;
	end;
end;

function TSDefinesSkiper.Defined(const VName : TSString) : TSBool;
var
	i : TSUInt32;
begin
Result := False;
if (FDefines <> nil) and (Length(FDefines) > 0) then
	for i := 0 to High(FDefines) do
		if FDefines[i].Name = VName then
			begin
			Result := True;
			break;
			end;
end;

function TSDefinesSkiper.Macro(const VName : TSString) : TSString;
var
	i : TSUInt32;
begin
Result := '';
if (FDefines <> nil) and (Length(FDefines) > 0) then
	for i := 0 to High(FDefines) do
		if FDefines[i].Name = VName then
			begin
			Result := FDefines[i].Value;
			break;
			end;
end;

procedure TSDefinesSkiper.ProcessInput(const VInputFile : TSString); overload;
var
	Stream : TStream = nil;
begin
Stream := TFileStream.Create(VInputFile, fmOpenRead);
ProcessInput(Stream);
Stream.Destroy();
Stream := nil;
end;

procedure TSDefinesSkiper.Run();
begin
ProcessInput(FGeneralInputFileName);
end;

constructor TSDefinesSkiper.Create();
begin
inherited;
FOutput := nil;
FOutputFileName := '';
FGeneralInputFileName := '';
FGeneralInputPath := '';
FDefines := nil;
end;

destructor TSDefinesSkiper.Destroy();
begin
KillOutput();
inherited;
end;

class function TSDefinesSkiper.ClassName() : TSString;
begin
Result := 'TSDefinesSkiper';
end;

procedure TSDefinesSkiper.SetInput (const VInputFile  : TSString);
begin
FGeneralInputFileName := VInputFile;
FGeneralInputPath := SFilePath(FGeneralInputFileName);
end;

procedure TSDefinesSkiper.SetOutput(const VOutputFile : TSString);
begin
FOutputFileName := VOutputFile;
KillOutput();
FOutput := TFileStream.Create(FOutputFileName, fmCreate);
end;

procedure TSDefinesSkiper.KillOutput();
begin
if FOutput <> nil then
	begin
	FOutput.Destroy();
	FOutput := nil;
	end;
end;

procedure SDefinesSkiper(const VInputFile, VOutputFile : TSString);
begin
with TSDefinesSkiper.Create() do
	begin
	Output := VOutputFile;
	Input  := VInputFile;
	Run();
	Destroy();
	end;
end;

operator =(const A, B : TSDefine) : TSBool; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := (A.Name = B.Name) and (A.Value = B.Value);
end;

{$DEFINE INC_PLACE_IMPLEMENTATION}
{$DEFINE DATATYPE_LIST_HELPER := TSDefineListHelper}
{$DEFINE DATATYPE_LIST        := TSDefineList}
{$DEFINE DATATYPE             := TSDefine}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}
{$UNDEF INC_PLACE_IMPLEMENTATION}

function SDefineCreate(const VName : TSString; const VValue : TSString = '') : TSDefine; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(VName, VValue);
end;

procedure TSDefine.Clear();
begin
Import('');
end;

procedure TSDefine.Import(const VName : TSString; const VValue : TSString = '');
begin
FName := VName;
FValue := VValue;
end;

end.
